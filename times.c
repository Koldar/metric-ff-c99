#include "times.h"
#include <stdio.h>
#include <stdlib.h>

#ifdef WINDOWS

	#include <windows.h>
	#include <sysinfoapi.h>
// #include <minwinbase.h>

	struct abstract_time {
		FILETIME t;
	};

	struct abstract_time* getCurrentTime() {
		struct abstract_time* result = malloc(sizeof(struct abstract_time));
		if (result == NULL) {
			fprintf(stderr, "memory finished\n");
			exit(1);
		}
		GetSystemTimeAsFileTime(&result->t);
		return result;
	}

	void freeAbstractTime(const struct abstract_time* t) {
		if (t != NULL) {
			free((struct abstract_time*)t);
		}
	}

	double getSecondsElapsed(const struct abstract_time* start, const struct abstract_time* end) {
		//see https://docs.microsoft.com/it-it/windows/win32/api/minwinbase/ns-minwinbase-filetime
		ULARGE_INTEGER startLarge, endLarge, diff;
		FILETIME result;
		startLarge.LowPart = start->t.dwLowDateTime;
		startLarge.HighPart = start->t.dwHighDateTime;
		endLarge.LowPart = end->t.dwLowDateTime;
		endLarge.HighPart = end->t.dwHighDateTime;
		diff.QuadPart = endLarge.QuadPart - startLarge.QuadPart;

		result.dwHighDateTime = diff.HighPart;
		result.dwLowDateTime = diff.LowPart;

		return result.dwLowDateTime * 100. / (1. * 1e9);
	}

	float getSecondsElapsed2(const struct abstract_time* start, const struct abstract_time* end) {
		return (float)getSecondsElapsed(start, end);
	}

	int getSecondsElapsed3(const struct abstract_time* start, const struct abstract_time* end) {
		return (int)getSecondsElapsed(start, end);
	}

#else
#if LINUX

	//see https://stackoverflow.com/a/17371925/1887602

	#define _POSIX_C_SOURCE 200809L

	#include <time.h>
	#include <sys/time.h>

	#include <inttypes.h>
	#include <math.h>
	#include <stdio.h>

	struct abstract_time {
		long milliseconds;
		time_t seconds;
		//struct timespec spec;
	};

	struct abstract_time* getCurrentTime() {
		// struct abstract_time* result = malloc(sizeof(struct abstract_time));
		// if (result == NULL) {
		// 	fprintf(stderr, "memory finished\n");
		// 	exit(1);
		// }

		// clock_gettime(CLOCK_MONOTONIC, &result->spec);

		// result->seconds  = result->spec.tv_sec;
		// result->milliseconds = round(result->spec.tv_nsec / 1.0e6); // Convert nanoseconds to milliseconds
		// if (ms > 999) {
		// 	s++;
		// 	ms = 0;
		// }

		// return result;
		return NULL;
	}

	void freeAbstractTime(const struct abstract_time* t) {
		if (t != NULL) {
			free((struct abstract_time*)t);
		}
	}

	double getSecondsElapsed(const struct abstract_time* start, const struct abstract_time* end) {
		// double result;

		// //seconds
		// result = (end->seconds - start->seconds);
		// if (end->milliseconds >= start->milliseconds) {
		// 	result += 1e-3*(end->milliseconds - start->milliseconds);
		// } else {
		// 	result -= 1e3;
		// 	result += 1e-3*(1e3 + (end->milliseconds - start->milliseconds)); //the quantity here is negative
		// }
		
		// return result;
		return 0;
	}

	float getSecondsElapsed2(const struct abstract_time* start, const struct abstract_time* end) {
		return (float)getSecondsElapsed(start, end);
	}

	int getSecondsElapsed3(const struct abstract_time* start, const struct abstract_time* end) {
		return (int)getSecondsElapsed(start, end);
	}

#else
#error "unrecognized operating system"
#endif

#endif