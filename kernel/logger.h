#ifndef LOGGER_H
#define LOGGER_H

// تعریف سطوح لاگ (با مقداردهی دلخواه)
// می‌توانید مقادیر را به گونه‌ای تنظیم کنید که در پروژه خود با استاندارد تعیین شده هماهنگ باشد.
#define LOG_INFO  0
#define LOG_WARN  1
#define LOG_ERROR 2

// اعلان تابع لاگ
void log_message(int level, const char *message);

#endif // LOGGER_H
