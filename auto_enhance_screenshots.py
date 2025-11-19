"""
Auto-enhance any screenshots found in Desktop/app_screenshots/
Works with any image files you have there
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import os
import glob

# Paths
DESKTOP = os.path.join(os.path.expanduser("~"), "Desktop")
INPUT_FOLDER = os.path.join(DESKTOP, "app_screenshots")
OUTPUT_FOLDER = os.path.join(DESKTOP, "promo_final")

# Create folders
os.makedirs(INPUT_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# Colors
PRIMARY_COLOR = (33, 150, 243)
ACCENT_COLOR = (76, 175, 80)
TEXT_COLOR = (255, 255, 255)

def create_gradient_overlay(width, height, position='top'):
    """Create gradient overlay"""
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    overlay_height = 350
    if position == 'top':
        for i in range(overlay_height):
            ratio = i / overlay_height
            alpha = int(200 * (1 - ratio))
            color = (*PRIMARY_COLOR, alpha)
            draw.line([(0, i), (width, i)], fill=color)
    else:
        start_y = height - overlay_height
        for i in range(overlay_height):
            ratio = i / overlay_height
            alpha = int(200 * ratio)
            color = (*PRIMARY_COLOR, alpha)
            draw.line([(0, start_y + i), (width, start_y + i)], fill=color)
    
    return overlay

def add_text_with_shadow(draw, text, position, font, text_color):
    """Add text with shadow"""
    x, y = position
    draw.text((x + 4, y + 4), text, font=font, fill=(0, 0, 0, 180))
    draw.text((x, y), text, font=font, fill=text_color)

def add_phone_frame(img):
    """Add phone frame"""
    width, height = img.size
    frame_thickness = 25
    corner_radius = 45
    
    frame_width = width + (frame_thickness * 2)
    frame_height = height + (frame_thickness * 2) + 80
    
    frame = Image.new('RGBA', (frame_width, frame_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(frame)
    
    draw.rounded_rectangle([0, 0, frame_width, frame_height], radius=corner_radius, fill=(40, 40, 40, 255))
    
    screen_y = 60
    draw.rounded_rectangle(
        [frame_thickness, screen_y + frame_thickness, frame_width - frame_thickness, frame_height - frame_thickness],
        radius=corner_radius - 10, fill=(0, 0, 0, 255)
    )
    
    notch_width = 180
    notch_height = 25
    notch_x = (frame_width - notch_width) // 2
    draw.rounded_rectangle([notch_x, screen_y, notch_x + notch_width, screen_y + notch_height], radius=12, fill=(40, 40, 40, 255))
    
    frame.paste(img, (frame_thickness, screen_y + frame_thickness), img if img.mode == 'RGBA' else None)
    
    shadow = Image.new('RGBA', (frame_width + 60, frame_height + 60), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle([15, 15, frame_width + 45, frame_height + 45], radius=corner_radius + 10, fill=(0, 0, 0, 80))
    shadow = shadow.filter(ImageFilter.GaussianBlur(25))
    
    final = Image.new('RGBA', shadow.size, (255, 255, 255, 255))
    final.paste(shadow, (0, 0), shadow)
    final.paste(frame, (30, 30), frame)
    
    return final

def process_screenshot(img_path, output_name, title, subtitle, position='top'):
    """Process a screenshot"""
    try:
        img = Image.open(img_path)
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        
        # Enhance
        enhancer = ImageEnhance.Contrast(img)
        img = enhancer.enhance(1.05)
        enhancer = ImageEnhance.Color(img)
        img = enhancer.enhance(1.1)
        img = img.filter(ImageFilter.SHARPEN)
        
        width, height = img.size
        overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        draw = ImageDraw.Draw(overlay)
        
        # Gradient
        gradient = create_gradient_overlay(width, height, position)
        overlay = Image.alpha_composite(overlay, gradient)
        draw = ImageDraw.Draw(overlay)
        
        # Fonts
        try:
            title_font = ImageFont.truetype("arialbd.ttf", 70)
            subtitle_font = ImageFont.truetype("arial.ttf", 45)
        except:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
        
        # Text positions
        if position == 'top':
            title_y, subtitle_y = 60, 150
        else:
            title_y, subtitle_y = height - 280, height - 190
        
        add_text_with_shadow(draw, title, (50, title_y), title_font, TEXT_COLOR)
        add_text_with_shadow(draw, subtitle, (50, subtitle_y), subtitle_font, TEXT_COLOR)
        
        # Composite
        result = Image.alpha_composite(img, overlay)
        result = add_phone_frame(result)
        
        # Save
        output_path = os.path.join(OUTPUT_FOLDER, output_name)
        result.save(output_path, 'PNG', quality=95)
        print(f"✅ Created: {output_name}")
        return True
    except Exception as e:
        print(f"❌ Error: {e}")
        return False

def main():
    print("=" * 70)
    print("Book Reader - Auto Screenshot Enhancement")
    print("=" * 70)
    print(f"\n📁 Looking for screenshots in: {INPUT_FOLDER}")
    
    # Find all images
    image_files = []
    for ext in ['*.png', '*.jpg', '*.jpeg']:
        image_files.extend(glob.glob(os.path.join(INPUT_FOLDER, ext)))
    
    if not image_files:
        print("\n⚠️  No screenshots found!")
        print(f"\nPlease save your screenshots to: {INPUT_FOLDER}")
        print("\nThen run this script again.")
        return
    
    print(f"\n📸 Found {len(image_files)} screenshot(s)")
    print("\n🎨 Processing...\n")
    
    # Process each image
    configs = [
        ("Your Digital Library", "All Books in One Place", "top"),
        ("Pick Up Where You Left", "Continue Reading Instantly", "bottom"),
        ("Easy Navigation", "Jump to Any Chapter", "top"),
        ("Immersive Reading", "Beautiful EPUB Experience", "bottom"),
        ("Smooth PDF Reading", "Zoom, Navigate & Bookmark", "top"),
        ("Never Lose Your Place", "Quick Access to Bookmarks", "bottom"),
    ]
    
    for i, img_path in enumerate(sorted(image_files)[:6]):
        if i < len(configs):
            title, subtitle, position = configs[i]
            output_name = f"0{i+1}_promo.png"
            process_screenshot(img_path, output_name, title, subtitle, position)
    
    # Create additional graphics
    print("\n🎨 Creating additional graphics...")
    
    # Feature graphic
    width, height = 1024, 500
    img = Image.new('RGB', (width, height), PRIMARY_COLOR)
    draw = ImageDraw.Draw(img)
    
    for i in range(height):
        ratio = i / height
        r = int(PRIMARY_COLOR[0] * (1 - ratio) + 100 * ratio)
        g = int(PRIMARY_COLOR[1] * (1 - ratio) + 200 * ratio)
        b = int(PRIMARY_COLOR[2] * (1 - ratio) + 255 * ratio)
        draw.line([(0, i), (width, i)], fill=(r, g, b))
    
    try:
        title_font = ImageFont.truetype("arialbd.ttf", 100)
        subtitle_font = ImageFont.truetype("arial.ttf", 48)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    add_text_with_shadow(draw, "Book Reader", (70, 110), title_font, (255, 255, 255))
    add_text_with_shadow(draw, "PDF & EPUB Reader for Android", (70, 240), subtitle_font, (255, 255, 255))
    
    img.save(os.path.join(OUTPUT_FOLDER, "feature_graphic.png"), 'PNG', quality=95)
    print("✅ Created: feature_graphic.png")
    
    # App icon
    size = 512
    img = Image.new('RGB', (size, size), PRIMARY_COLOR)
    draw = ImageDraw.Draw(img)
    
    for i in range(size):
        ratio = i / size
        r = int(PRIMARY_COLOR[0] * (1 - ratio) + 100 * ratio)
        g = int(PRIMARY_COLOR[1] * (1 - ratio) + 200 * ratio)
        b = int(PRIMARY_COLOR[2] * (1 - ratio) + 255 * ratio)
        draw.line([(0, i), (size, i)], fill=(r, g, b))
    
    try:
        icon_font = ImageFont.truetype("seguiemj.ttf", 280)
    except:
        icon_font = ImageFont.load_default()
    
    draw.text((110, 90), "📚", font=icon_font, fill=(255, 255, 255))
    draw.rectangle([0, 0, size-1, size-1], outline=(255, 255, 255), width=12)
    
    img.save(os.path.join(OUTPUT_FOLDER, "app_icon.png"), 'PNG', quality=95)
    print("✅ Created: app_icon.png")
    
    print("\n" + "=" * 70)
    print("✅ All promotional materials created!")
    print(f"📁 Location: {OUTPUT_FOLDER}")
    print("=" * 70)
    print("\n✨ Ready for Softonic submission!")

if __name__ == "__main__":
    main()
