//
//  SKCanvas.swift
//  SkiaKit
//
//  Created by Miguel de Icaza on 10/15/19.
//  Copyright © 2019 Miguel de Icaza. All rights reserved.
//

import Foundation

/**
 * `Canvas` provides an interface for drawing, and how the drawing is clipped and transformed.
 * `Canvas` contains a stack of `Matrix` and clip values.
 *
 * `Canvas` and `Paint` together provide the state to draw into `Surface` or `BaseDevice`.
 * Each `Canvas` draw call transforms the geometry of the object by the concatenation of all
 * `Matrix` values in the stack. The transformed geometry is clipped by the intersection
 * of all of clip values in the stack. The `Canvas` draw calls use `Paint` to supply drawing
 * state such as color, `Typeface`, text size, stroke width, `Shader` and so on.
 *
 * To draw to a pixel-based destination, create raster surface or GPU surface.
 * Request `Canvas` from `Surface` to obtain the interface to draw.
 * `Canvas` generated by raster surface draws to memory visible to the CPU.
 * `Canvas` generated by GPU surface uses Vulkan or OpenGL to draw to the GPU.
 *
 * To draw to a document, obtain `Canvas` from SVG canvas, document PDF, or `PictureRecorder`.
 * `Document` based `Canvas` and other `Canvas` subclasses reference `BaseDevice` describing the
 * destination.
 *
 * `Canvas` can be constructed to draw to `Bitmap` without first creating raster surface.
 * This approach may be deprecated in the future.

 */
public class Canvas {
    var handle: OpaquePointer
    var owns: Bool
    
    public init (_ bitmap : Bitmap)
    {
        handle = sk_canvas_new_from_bitmap(bitmap.handle)
        owns = true
    }
    
    init (handle: OpaquePointer, owns: Bool)
    {
        self.handle = handle
        self.owns = owns
    }
    
    deinit {
        if owns {
            sk_canvas_destroy(handle)
        }
    }
    
    public func drawText (text: String, x: Float, y: Float, paint: Paint)
    {
        let utf8 = text.utf8CString
        
        sk_canvas_draw_text(handle, text, utf8.count, x, y, paint.handle)
    }
    
    public func quickReject (rect: Rect) -> Bool
    {
        withUnsafePointer(to: rect.toNative()) {
            sk_canvas_quick_reject(handle, $0)
        }
    }
    
//    public func quickReject (path: Path) -> Bool
//    {
//
//    }
    
    // TODO: saveLayer
    
    public func save () -> Int32
    {
        sk_canvas_save(handle)
    }
    
    /**
     * Fills clip with color color.
     * mode determines how ARGB is combined with destination.
     * - Parameter color: unpremultiplied ARGB
     * - Parameter blendMode: `BlendMode` used to combine source color and destination
     */
    public func drawColor (_ color: Color, blendMode: BlendMode = .src)
    {
        sk_canvas_draw_color(handle, color.color, blendMode.toNative())
    }
    
    /**
     * Draws line segment from p0 to p1 using clip, `Matrix`, and `Paint` paint.
     * In paint: `Paint` stroke width describes the line thickness;
     * `Paint.cap` draws the end rounded or square;
     * `Paint.style` is ignored, as if were set to `.stroke`
     * - Parameter p0: start of line segment
     * - Parameter p1: end of line segment
     * - Parameter paint: stroke, blend, color, and so on, used to draw
     */
    public func drawLine (_ p0: Point, _ p1: Point, paint: Paint)
    {
        sk_canvas_draw_line(handle, p0.x, p0.y, p1.x, p1.y, paint.handle)
    }

    /**
     * Draws line segment from (x0, y0) to (x1, y1) using clip, `Matrix`, and `Paint` paint.
     * In paint: `Paint` stroke width describes the line thickness;
     * `Paint.cap` draws the end rounded or square;
     * `Paint.style` is ignored, as if were set to `.stroke`
     * - Parameter x0: start of line segment on x-axis
     * - Parameter y0: start of line segment on y-axis
     * - Parameter x1: end of line segment on x-axis
     * - Parameter y1: end of line segment on y-axis
     * - Parameter paint: stroke, blend, color, and so on, used to draw
     */
    public func drawLine (x0: Float, y0: Float, x1: Float, y1: Float, paint: Paint)
    {
        sk_canvas_draw_line(handle, x0, y0, x1, y1, paint.handle)
    }

    public func clear ()
    {
        drawColor(Colors.empty, blendMode: .src)
    }
    
    /**
     * Fills clip with color color using `BlendMode`::kSrc.
     * This has the effect of replacing all pixels contained by clip with color.
     * - Parameter color: unpremultiplied ARGB
     */
    public func clear (color: Color)
    {
        drawColor(color, blendMode: .src)
    }
    
    /**
     * Removes changes to `Matrix` and clip since `Canvas` state was
     * last saved. The state is removed from the stack.
     * Does nothing if the stack is empty.
     * example: https://fiddle.skia.org/c/@AutoCanvasRestore_restore
     * example: https://fiddle.skia.org/c/@Canvas_restore
     */
    public func restore ()
    {
        sk_canvas_restore(handle)
    }
    
    /**
     * Restores state to `Matrix` and clip values when `save()`, `saveLayer()`,
     * `saveLayerPreserveLCDTextRequests()`, or `saveLayerAlpha()` returned `count`.
     * Does nothing if `count` is greater than state stack count.
     * Restores state to initial values if `count` is less than or equal to one.
     * - Parameter count: depth of state stack to restore
     */
    public func restoreToCount (count: Int32)
    {
        sk_canvas_restore_to_count(handle, count)
    }
    
    /**
     * Translates `Matrix` by dx along the x-axis and dy along the y-axis.
     * Mathematically, replaces `Matrix` with a translation matrix
     * premultiplied with `Matrix`.
     * This has the effect of moving the drawing by (dx, dy) before transforming
     * the result with `Matrix`.
     * - Parameter dx: distance to translate on x-axis
     * - Parameter dy: distance to translate on y-axis
     */
    public func translate (dx: Float, dy: Float)
    {
        sk_canvas_translate(handle, dx, dy)
    }

    /**
     * Translates `Matrix` by dx along the x-axis and dy along the y-axis.
     * Mathematically, replaces `Matrix` with a translation matrix
     * premultiplied with `Matrix`.
     * This has the effect of moving the drawing by `pt` before transforming
     * the result with `Matrix`.
     * - Parameter pt: distance to translate on x-axis and y-axis
     */
    public func translate (pt: Point)
    {
        sk_canvas_translate(handle, pt.x, pt.y)
    }
    
    /**
     * Scales `Matrix` by `scale` on the x-axis and  y-axis.
     * Mathematically, replaces `Matrix` with a scale matrix
     * premultiplied with `Matrix`.
     * This has the effect of scaling the drawing by (sx, sy) before transforming
     * the result with `Matrix`.
     * - Parameter scale: amount to scale on both axis
     */
    public func scale (_ scale: Float)
    {
        sk_canvas_scale (handle, scale, scale)
    }
    
    /**
     * Scales `Matrix` by sx on the x-axis and sy on the y-axis.
     * Mathematically, replaces `Matrix` with a scale matrix
     * premultiplied with `Matrix`.
     * This has the effect of scaling the drawing by (sx, sy) before transforming
     * the result with `Matrix`.
     * - Parameter sx: amount to scale on x-axis
     * - Parameter sy: amount to scale on y-axis
     */
    public func scale (sx: Float, sy: Float)
    {
        sk_canvas_scale (handle, sx, sy)
    }
    
    /**
     * Scales `Matrix` by sx on the x-axis and sy on the y-axis.
     * Mathematically, replaces `Matrix` with a scale matrix
     * premultiplied with `Matrix`.
     * This has the effect of scaling the drawing by (sx, sy) before transforming
     * the result with `Matrix`.
     * - Parameter factor: the scale encoded as a point
     */
    public func scale (factor: Point)
    {
        sk_canvas_scale(handle, factor.x, factor.y)
    }
    
    /**
     *
     * - Parameter pivot: the pivot point for the scale to take place
     */
    public func scale (sx: Float, sy: Float, pivot: Point)
    {
        translate(pt: pivot)
        scale (sx: sx, sy: sy)
        translate (pt: -pivot)
    }
    
    /**
     * Rotates `Matrix` by degrees. Positive degrees rotates clockwise.
     * Mathematically, replaces `Matrix` with a rotation matrix
     * premultiplied with `Matrix`.
     * This has the effect of rotating the drawing by degrees before transforming
     * the result with `Matrix`.
     * - Parameter degrees: amount to rotate, in degrees
     */
    public func rotate (degrees: Float)
    {
        sk_canvas_rotate_degrees(handle, degrees)
    }

    /**
     * Rotates `Matrix` by radians. Positive values rotates clockwise.
     * Mathematically, replaces `Matrix` with a rotation matrix
     * premultiplied with `Matrix`.
     * This has the effect of rotating the drawing by radians before transforming
     * the result with `Matrix`.
     * - Parameter degrees: amount to rotate, in radians
     */
    public func rotate (radians: Float)
    {
        sk_canvas_rotate_radians(handle, radians)
    }
    
    public func rotate (degrees: Float, pivot: Point)
    {
        translate(pt: pivot)
        sk_canvas_rotate_degrees(handle, degrees)
        translate(pt: -pivot)
    }
    
    public func rotate (radians: Float, pivot: Point)
    {
        translate(pt: pivot)
        sk_canvas_rotate_radians(handle, radians)
        translate(pt: -pivot)
    }
    
    public func skew (sx: Float, sy: Float)
    {
        sk_canvas_skew(handle,sx, sy)
    }
    
//    public func concat (matrix: inout Matrix)
//    {
//
//    }
    
    public func clip (rect: Rect, operation: ClipOperation = .intersect, antialias: Bool = false)
    {
        withUnsafePointer(to: rect.toNative()) {
            sk_canvas_clip_rect_with_operation(handle, $0, operation.toNative (), antialias)
        }
    }
    
    public func clip (roundedRect: RoundRect, operation: ClipOperation = .intersect, antialias: Bool = false)
    {
        sk_canvas_clip_rrect_with_operation(handle, roundedRect.handle, operation.toNative(), antialias)
    }
    
    public func clip (path: Path, operation: ClipOperation = .intersect, antialias: Bool = false)
    {
        sk_canvas_clip_path_with_operation(handle, path.handle, operation.toNative(), antialias)
    }
    
    public func clip (region: Region, operation: ClipOperation = .intersect)
    {
        sk_canvas_clip_region(handle, region.handle, operation.toNative())
    }
    
    public var localClipBounds : Rect {
        get {
            let (b, _) = getLocalClipBounds()
            return b
        }
    }
    
    public var deviceClipounds: IRect {
        get {
            let (b, _) = getDeviceClipBounds()
            return b
        }
    }
    public func getLocalClipBounds () -> (bounds: Rect, empty: Bool)
    {
        let bounds = UnsafeMutablePointer<sk_rect_t>.allocate(capacity: 1);
        
        let notEmpty = sk_canvas_get_local_clip_bounds(handle, bounds)
        return (Rect.fromNative (bounds.pointee), !notEmpty)
    }
    
    public func getDeviceClipBounds () -> (bounds: IRect, empty: Bool)
    {
        let bounds = UnsafeMutablePointer<sk_irect_t>.allocate(capacity: 1);
        
        let notEmpty = sk_canvas_get_device_clip_bounds(handle, bounds)
        return (IRect.fromNative (bounds.pointee), !notEmpty)
    }
    
    public func draw (_ paint: Paint)
    {
        sk_canvas_draw_paint (handle, paint.handle)
    }
    
    public func drawRegion (_ region: Region, _ paint: Paint)
    {
        sk_canvas_draw_region(handle, region.handle, paint.handle)
    }
    
    public func drawRect (_ rect: Rect, _ paint: Paint)
    {
        withUnsafePointer(to: rect.toNative()) { ptr in
            sk_canvas_draw_rect(handle, ptr, paint.handle)
        }
    }
    
    public func drawRoundRect (_ roundedRect: RoundRect, _ paint: Paint)
    {
        sk_canvas_draw_rrect(handle, roundedRect.handle, paint.handle)
    }
    
    public func drawRoundRect (_ rect: Rect, rx: Float, ry: Float, _ paint: Paint)
    {
        withUnsafePointer(to: rect.toNative()) { ptr in
            sk_canvas_draw_round_rect(handle, ptr, rx, ry, paint.handle)
        }
    }
        
    public func drawOval (_ rect: Rect, paint: Paint)
    {
        withUnsafePointer(to: rect.toNative()) { ptr in
            sk_canvas_draw_oval(handle, ptr, paint.handle)
        }
    }
    
    public func drawCircle (_ cx: Float, _ cy: Float, _ radius: Float, _ paint: Paint)
    {
        sk_canvas_draw_circle(handle, cx, cy, radius, paint.handle)
    }
    
    public func drawCircle (_ point: Point, _ radius: Float, _ paint: Paint)
    {
        sk_canvas_draw_circle(handle, point.x, point.y, radius, paint.handle)
    }
    
    public func drawPath (_ path: Path, _ paint: Paint)
    {
        sk_canvas_draw_path(handle, path.handle, paint.handle)
    }
    
    public func drawPoints (_ pointMode: PointMode, _ points: [Point], _ paint: Paint)
    {
        var nativePoints: [sk_point_t] = []
        for x in points {
            nativePoints.append(x.toNative ())
        }
        
        sk_canvas_draw_points(handle, pointMode.toNative(), points.count, nativePoints, paint.handle)
    }
    
    public func drawPoint (_ x: Float, _ y: Float, _ paint: Paint)
    {
        sk_canvas_draw_point(handle, x, y, paint.handle)
    }
    
    public func drawPoint (_ x: Float, _ y: Float, _ color: Color)
    {
        let paint = Paint()
        paint.color = color
        drawPoint (x, y, paint)
    }
    
    public func drawImage (_ image: Image, _ x: Float, _ y: Float, _ paint: Paint? = nil)
    {
        sk_canvas_draw_image(handle, image.handle, x, y, paint == nil ? nil : paint!.handle)
    }
    
    public func drawImage (_ image: Image, _ dest: Rect, _ paint: Paint? = nil)
    {
        withUnsafePointer(to: dest.toNative()) { ptr in
            sk_canvas_draw_image_rect(handle, image.handle, nil, ptr, paint == nil ? nil : paint!.handle)
        }
    }
    
    public func drawImage (_ image: Image, source: Rect, dest: Rect, _ paint: Paint? = nil)
    {
        withUnsafePointer(to: dest.toNative()) { destPtr in
            withUnsafePointer(to: source.toNative()) { srcPtr in
                sk_canvas_draw_image_rect(handle, image.handle, srcPtr, destPtr, paint == nil ? nil : paint!.handle)
            }
        }
    }
    
    // TODO drawPicture
    // TODO drawDrawable
    
    public func drawBitmap (_ bitmap: Bitmap, _ point: Point, _ paint: Paint? = nil)
    {
        drawBitmap(bitmap, point.x, point.y, paint)
    }
    
    public func drawBitmap (_ bitmap: Bitmap, _ left: Float, _ top: Float, _ paint: Paint? = nil )
    {
        sk_canvas_draw_bitmap(handle, bitmap.handle, left, top, paint == nil ? nil : paint!.handle)
    }

    public func drawBitmap (_ bitmap: Bitmap, _ dest: Rect, _ paint: Paint? = nil )
    {
        withUnsafePointer(to: dest.toNative()) { rectPtr in
            sk_canvas_draw_bitmap_rect(handle, bitmap.handle, nil, rectPtr, paint == nil ? nil : paint!.handle)
        }
    }

    /**
     * Draws `Rect` src of `Bitmap` bitmap, scaled and translated to fill `Rect` dst.
     * Additionally transform draw using clip, `Matrix`, and optional `Paint` paint.
     *
     * If `Paint` paint is supplied, apply `ColorFilter`, alpha, `ImageFilter`,
     * `BlendMode`, and `DrawLooper`. If bitmap is `.alpha8`, apply `Shader`.
     *
     * If paint contains `MaskFilter`, generate mask from bitmap bounds.
     *
     * If generated mask extends beyond bitmap bounds, replicate bitmap edge colors,
     * just as `Shader` made from `Shader`::MakeBitmapShader with
     * `Shader`::kClamp_TileMode set replicates the bitmap edge color when it samples
     * outside of its bounds.
     *
     * - Parameter bitmap: `Bitmap` containing pixels, dimensions, and format
     * - Parameter source: source `Rect` of image to draw from
     * - Parameter dest: destination `Rect` of image to draw to
     * - Parameter paint: `Paint` containing `BlendMode`, `ColorFilter`, `ImageFilter`,
     * and so on; or nullptr

     */
    public func drawBitmap (_ bitmap: Bitmap, source: Rect, dest: Rect, _ paint: Paint? = nil )
    {
        withUnsafePointer(to: dest.toNative()) { destPtr in
            withUnsafePointer(to: source.toNative()) { srcPtr in
                sk_canvas_draw_bitmap_rect(handle, bitmap.handle, srcPtr, destPtr, paint == nil ? nil : paint!.handle)
            }
        }
    }

    // TODO: drawSurface
    
    public func drawText (_ text: String, _ x: Float, _ y: Float, paint: Paint)
    {
        sk_canvas_draw_text(handle, text, text.utf8CString.count, x, y, paint.handle)
    }

    /**
     * Draws `TextBlob` blob at (x, y), using clip, `Matrix`, and `Paint` paint.
     * blob contains glyphs, their positions, and paint attributes specific to text:
     * `Typeface`, `Paint` text size, `Paint` text scale x,
     * `Paint` text skew x, `Paint`::Align, `Paint`::Hinting, anti-alias, `Paint` fake bold,
     * `Paint` font embedded bitmaps, `Paint` full hinting spacing, LCD text, `Paint` linear text,
     * and `Paint` subpixel text.
     *
     * `TextEncoding` must be set to `TextEncoding`::kGlyphID.
     *
     * Elements of paint: anti-alias, `BlendMode`, color including alpha,
     * `ColorFilter`, `Paint` dither, `DrawLooper`, `MaskFilter`, `PathEffect`, `Shader`, and
     * `Paint`::Style; apply to blob. If `Paint` contains `Paint`::kStroke_Style:
     * `Paint` miter limit, `Paint`::Cap, `Paint`::Join, and `Paint` stroke width;
     * apply to `Path` created from blob.
     *
     * - Parameter textBlob: glyphs, positions, and their paints' text size, typeface, and so on
     * - Parameter x: horizontal offset applied to blob
     * - Parameter y: vertical offset applied to blob
     * - Parameter paint: blend, color, stroking, and so on, used to draw
     *
     * example: https://fiddle.skia.org/c/@Canvas_drawTextBlob
     */
    public func drawTextBlob (_ textBlob: TextBlob, _ x: Float, _ y: Float, paint: Paint)
    {
        sk_canvas_draw_text_blob(handle, textBlob.handle, x, y, paint.handle)
    }
    
    public func drawPositionedText (_ text: String, _ points: [Point], _ paint: Paint)
    {
        var nativePoints: [sk_point_t] = []
        for x in points {
            nativePoints.append(x.toNative ())
        }
        
        sk_canvas_draw_pos_text(handle, text, text.utf8CString.count, nativePoints, paint.handle)
    }
    
    public func drawTextOnPath (_ text: String, _ path: Path, _ hOffset: Float, _ vOffset: Float, _ paint: Paint)
    {
        sk_canvas_draw_text_on_path(handle, text, text.utf8CString.count, path.handle, hOffset, vOffset, paint.handle)
    }
    
    /**
     * Triggers the immediate execution of all pending draw operations.
     * If `Canvas` is associated with GPU surface, resolves all pending GPU operations.
     * If `Canvas` is associated with raster surface, has no effect; raster draw
     * operations are never deferred.
     */
    public func flush ()
    {
        sk_canvas_flush(handle)
    }
    
    public func drawBitmapNinePatch (_ bitmap: Bitmap, _ center: IRect, _ dest: Rect, _ paint: Paint? = nil)
    {
        withUnsafePointer(to: dest.toNative()) { destPtr in
            withUnsafePointer(to: center.toNative()) { centerPtr in
                sk_canvas_draw_bitmap_nine(handle, bitmap.handle, centerPtr, destPtr, paint == nil ? nil : paint!.handle)
            }
        }
    }
    
    public func drawImageNinePatch (_ image: Image, _ center: IRect, _ dest: Rect, _ paint: Paint? = nil)
    {
        withUnsafePointer(to: dest.toNative()) { destPtr in
            withUnsafePointer(to: center.toNative()) { centerPtr in
                sk_canvas_draw_image_nine(handle, image.handle, centerPtr, destPtr, paint == nil ? nil : paint!.handle)
            }
        }
    }
    
    // TODO: drawAnnotation
    // TODO: drawUrlAnnotation
    // TODO: drawNamedDestinationAnnotation
    // TODO: drawLinkDestinationAnnotation
    // TODO: DrawBitmapLattice
    // TODO: DrawImageLattice
    // TODO: drawVertices

    /**
     * Sets `Matrix` to the identity matrix.
     * Any prior matrix state is overwritten.
    */
    public func resetMatrix ()
    {
        sk_canvas_reset_matrix(handle)
    }
    
    /**
     * Replaces `Matrix` with matrix.
     * Unlike concat(), any prior matrix state is overwritten.
     * - Parameter matrix: matrix to copy, replacing existing `Matrix`
     * example: https://fiddle.skia.org/c/@Canvas_setMatrix
     */
    public func setMatrix (_ matrix: Matrix)
    {
        withUnsafePointer (to: matrix.toNative()) { matrixPtr in
            sk_canvas_set_matrix(handle, matrixPtr)
        }
    }
    
    /**
     * Returns `Matrix`.
     * This does not account for translation by `BaseDevice` or `Surface`.
     * - Returns: `Matrix` in `Canvas`
     * example: https://fiddle.skia.org/c/@Canvas_getTotalMatrix
     * example: https://fiddle.skia.org/c/@Clip
     */
    public var totalMatrix: Matrix {
        get {
            let matrix = UnsafeMutablePointer<sk_matrix_t>.allocate(capacity: 1);
            sk_canvas_get_total_matrix(handle, matrix)
            return Matrix.fromNative (m: matrix.pointee)
        }
    }
    
    /**
     * Returns the number of saved states, each containing: `Matrix` and clip.
     * Equals the number of save() calls less the number of restore() calls plus one.
     * The save count of a new canvas is one.
     * - Returns: depth of save state stack
     * example: https://fiddle.skia.org/c/@Canvas_getSaveCount
     */
    public var saveCount: Int32 {
        get {
            sk_canvas_get_save_count(handle)
        }
    }
}
