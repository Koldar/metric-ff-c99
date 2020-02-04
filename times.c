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

	freeAbstractTime(const struct abstract_time* t) {
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

	struct abstract_time {
		int t;
	};

	struct abstract_time* getCurrentTime() {
		return NULL;
	}

	freeAbstractTime(const struct abstract_time* t) {
		if (t != NULL) {
			free((struct abstract_time*)t);
		}
	}

	double getSecondsElapsed(const struct abstract_time* start, const struct abstract_time* end) {
		return 0.0;
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