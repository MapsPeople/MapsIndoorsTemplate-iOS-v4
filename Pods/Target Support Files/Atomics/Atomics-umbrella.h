#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HOPAtomicBoolean.h"
#import "HOPAtomicInteger.h"
#import "HOPAtomicReference.h"

FOUNDATION_EXPORT double AtomicsVersionNumber;
FOUNDATION_EXPORT const unsigned char AtomicsVersionString[];

