#include "kernel/types.h"
#include "kernel/stat.h"
#include "user/user.h"
#include "kernel/param.h"
#include "kernel/riscv.h"

#define NUM_BINS 7

static const uint allocation_sizes[NUM_BINS] = {
    32, 64, 128, 256, 512, 1024, 2048
};

typedef long Align;

struct PageInfo;

union Header {
    struct {
        union Header *next;
        struct PageInfo *page; 
    } s;

    Align x;
};

typedef union Header Header;

struct PageInfo {
    uint allocation_size; //в какую из карзин соответствует страница. при ЭТОМ если область больше 2048 б то это означает количество требуемых страниц
    uint total_blocks;
    uint free_blocks; //количество свободных блоков
    uint is_large; //проверка на то, какого размера блок 
    struct PageInfo *next;
};


static Header *free_lists[NUM_BINS];// массив голов свободных списков
static Header *large_free_list;
static struct PageInfo *pages;//отдельный список всех страниц, полученных аллокаторо 
static Header *large_malloc(uint nbytes);
static void release_free_pages(void);

static int
get_bin(uint nbytes) // чfile:157: *** recipe commences before first target.  Stop.

{
    uint required;

    required = nbytes + sizeof(Header); // потому что размер хедера учитываемм 

    for (int i = 0; i < NUM_BINS; i++) {
        if (required <= allocation_sizes[i])
            return i;
    }

    return -1;
}

static struct PageInfo *
morecore(int bin)   //в какой-то степени реализация проще чем в K&R потому что выделяем четко страничку
{
    char *mem;
    struct PageInfo *page;
    uint block_size;
    uint available;
    uint total_blocks;

    block_size = allocation_sizes[bin];

    mem = sbrk(PGSIZE);

    if (mem == (char *)-1) // проверяем что нормально выделилась память 
        return 0;
    page = (struct PageInfo *)mem;

    available = PGSIZE - sizeof(struct PageInfo);
    total_blocks = available / block_size;

    page->allocation_size = block_size;
    page->total_blocks = total_blocks;
    page->free_blocks = total_blocks;
    page->is_large = 0;

    page->next = pages; //добавили страницк в список общих 
    pages = page;

    for (uint i = 0; i < total_blocks; i++) { //генерируем блоки в новой странице
        Header *h;

        h = (Header *)(mem + sizeof(struct PageInfo)
                       + i * block_size);

        h->s.page = page;

        h->s.next = free_lists[bin]; // пушим их в фри лист
        free_lists[bin] = h;
    }

    return page;
}



void *
malloc(uint nbytes)
{
    int bin;
    Header *h;
    struct PageInfo *page;

    if (nbytes == 0)
        return 0;
    bin = get_bin(nbytes);

    if (bin == -1) {
        h = large_malloc(nbytes);

        if (h == 0)
            return 0;

        return (void *)(h + 1);
    }

    if (free_lists[bin] == 0) { //     // Если корзина пуста, получаем новую страницу.
        if (morecore(bin) == 0)
            return 0;
    }
    h = free_lists[bin];   // Забираем первый свободный блок.
    free_lists[bin] = h->s.next;

    page = h->s.page;
    page->free_blocks--;

    return (void *)(h + 1);
}

void
free(void *ap)
{
    Header *h;
    struct PageInfo *page;
    int bin;

    if (ap == 0)
        return;

    h = (Header *)ap - 1;
    page = h->s.page;

    if (page->is_large) {
        page->free_blocks = 1;

        h->s.next = large_free_list;
        large_free_list = h;

        release_free_pages();

        return;
    }
    bin = get_bin(page->allocation_size - sizeof(Header));

    page->free_blocks++;

    h->s.next = free_lists[bin];
    free_lists[bin] = h;

    release_free_pages();
}

static Header *
large_malloc(uint nbytes)
{
    char *mem;
    Header *h;
    struct PageInfo *page;
    Header *prev;
    Header *curr;

    uint required;
    uint num_pages;

    required = sizeof(struct PageInfo) + sizeof(Header) + nbytes;

    num_pages = (required + PGSIZE - 1) / PGSIZE; 

    prev = 0;// Ищем подходящую свободную область.
    curr = large_free_list;

    while (curr != 0) {// ищем свободною облсть
        page = curr->s.page;
        if (page->allocation_size * PGSIZE >= required) {
            if (prev == 0)
                large_free_list = curr->s.next;
            else
                prev->s.next = curr->s.next;
            page->free_blocks = 0;
            curr->s.next = 0;

            return curr;
        }

        prev = curr;
        curr = curr->s.next;
    }
    mem = sbrk(num_pages * PGSIZE);     // Подходящей свободной области нет — запрашиваем память.

    if (mem == (char *)-1)
        return 0;

    page = (struct PageInfo *)mem;

    page->allocation_size = num_pages;
    page->total_blocks = 1;
    page->free_blocks = 0;
    page->is_large = 1;

    page->next = pages;
    pages = page;

    h = (Header *)(mem + sizeof(struct PageInfo));
    h->s.page = page;
    h->s.next = 0;

    return h;
}

static int
is_page_free(struct PageInfo *page)
{
    return page->free_blocks == page->total_blocks;
}

static void
remove_from_free_list(struct PageInfo *page, int bin)
{
    Header **link = &free_lists[bin];

    while (*link != 0) { //недостаточно сдвинуть страницу. нжуно еще и очистись список
        if ((*link)->s.page == page) {
            *link = (*link)->s.next;
        } else {
            link = &(*link)->s.next;
        }
    }
}

static void
remove_from_large_free_list(Header *h) //тоже самое но для больших списков
{
    Header **link = &large_free_list;

    while (*link != 0) {
        if (*link == h) {
            *link = (*link)->s.next;
            return;
        }

        link = &(*link)->s.next;
    }
}

static void
release_free_pages(void)
{
    struct PageInfo *page;
    struct PageInfo *next;
    Header *h;

    while (pages != 0) {
        page = pages;
        if (!is_page_free(page))  // Проверяем, полностью ли свободен регион.

            break;

        next = page->next;

        if (page->is_large) {
            h = (Header *)((char *)page + sizeof(struct PageInfo));  // Header большой аллокации находитсясразу после PageInfo.

            remove_from_large_free_list(h);
        } else {
            int bin = -1;
            for (int i = 0; i < NUM_BINS; i++) {
                if (allocation_sizes[i] == page->allocation_size) {
                    bin = i;
                    break;
                }
            }

            if (bin == -1)
                return;

            remove_from_free_list(page, bin);
        }

        pages = next;

        uint bytes = page->is_large  // Определяем, сколько памяти возвращать.

                   ? page->allocation_size * PGSIZE
                   : PGSIZE;

        if (sbrk(-(int)bytes) == (char *)-1) {
            page->next = pages;
            pages = page;

            if (page->is_large) {
                h = (Header *)((char *)page + sizeof(struct PageInfo));
                h->s.next = large_free_list;
                large_free_list = h;
            } else {
                int bin = 0;

                while (allocation_sizes[bin] != page->allocation_size)
                    bin++;

                char *mem = (char *)page;

                uint total_blocks =
                    (PGSIZE - sizeof(struct PageInfo))
                    / page->allocation_size;

                for (uint i = 0; i < total_blocks; i++) {
                    h = (Header *)(mem + sizeof(struct PageInfo)
                                   + i * page->allocation_size);

                    h->s.next = free_lists[bin];
                    free_lists[bin] = h;
                }
            }

            return;
        }
    }
}
