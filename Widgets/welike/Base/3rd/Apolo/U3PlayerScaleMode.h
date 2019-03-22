//
//  U3PlayerScaleMode.h
//  d2
//
//

#ifndef d2_U3PlayerScaleMode_h
#define d2_U3PlayerScaleMode_h

/* old
typedef enum {
    AspectFullMode = 1, // scale to full screen
    AspectCropToFullMode = 2,
    OriginalMode = 3, // to be supported
    Force16x9FillMode = 4, // to be supported
    Force4x3FillMode = 5, // to be supported
    LastScaleMode = 6 // help to enumerate view modes
} U3PlayerScaleMode;
 */

// TMP FIXME: this modification currupt the sdk boundary. please use VideoRenderingScaleMode.h for now.
typedef enum {
    kVideoRenderingScaleModeKeepOriginal = 0, // Don't scale any more. Keep original size. Centered,
    kVideoRenderingScaleModeAspectFit = 1, // Scale to fit the view bounds, keeping aspect ratio
    kVideoRenderingScaleModeAspectFill = 2, // Scale to fill whole view, keeping aspect ratio. Some parts might be cropped
    kVideoRenderingScaleModeFill = 3, // Scale to fill whole view, keeping everything inside but ignoring aspect ratio
    kVideoRenderingScaleModeForce16x9Fit = 4, // Force 16:9 scale and fit the view
    kVideoRenderingScaleModeForce4x3Fit = 5, // Force 4:3 scale and fit the view
    kVideoRenderingScaleModeNone = 6,
    kFirstVideoRenderingScaleMode = kVideoRenderingScaleModeKeepOriginal,
    kMaximumVideoRenderingScaleMode = kVideoRenderingScaleModeForce4x3Fit,
    kVideoRenderingScaleModeDefault = kVideoRenderingScaleModeAspectFit,
} VideoRenderingScaleMode;

/*
 Android:
 typedef enum {
 kVideoRenderingScaleModeKeepOriginal = 0, // Don't scale any more. Keep original size. Centered,
 kVideoRenderingScaleModeAspectFit = 1, // Scale to fit the view bounds, keeping aspect ratio
 kVideoRenderingScaleModeAspectFill = 2, // Scale to fill whole view, keeping aspect ratio. Some parts might be cropped
 kVideoRenderingScaleModeFill = 3, // Scale to fill whole view, keeping everything inside but ignoring aspect ratio
 kVideoRenderingScaleModeForce16x9Fit = 4, // Force 16:9 scale and fit the view
 kVideoRenderingScaleModeForce4x3Fit = 5, // Force 4:3 scale and fit the view
 kVideoRenderingScaleModeNone = 6,
 kFirstVideoRenderingScaleMode = kVideoRenderingScaleModeKeepOriginal,
 kMaximumVideoRenderingScaleMode = kVideoRenderingScaleModeForce4x3Fit,
 kVideoRenderingScaleModeDefault = kVideoRenderingScaleModeAspectFit,
 } VideoRenderingScaleMode;
 // FIXME: merge to U3Pla
*/

#endif
