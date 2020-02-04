#ifndef _TIMES_HEADER__
#define _TIMES_HEADER__


struct abstract_time;

/**
* get cyrrent time. The time unit depends on the platform.
*
 * @note on windows it is milliseconds, on linux cpu time

 the return value needs to be freed maually
*/
struct abstract_time* getCurrentTime();

void freeAbstractTime(const struct abstract_time* t);

double getSecondsElapsed(const struct abstract_time* start, const struct abstract_time* end);

float getSecondsElapsed2(const struct abstract_time* start, const struct abstract_time* end);

int getSecondsElapsed3(const struct abstract_time* start, const struct abstract_time* end);

#endif