"""
Book Reader - Process Real App Screenshots
Creates professional promotional images from your actual app screenshots
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import os

# Output folder
OUTPUT_FOLDER = os.path.join(os.path.expanduser("~"), "Desktop", "promo_final")
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# Colors matching your app
PRIMARY_COLOR = (33, 150, 243)  # Blue
ACCENT_COLOR = (76, 175, 80)  # Green (from your app)
GRADIENT_START = (33, 150, 243, 200)
GRADIENT_END = (100, 200, 255, 200)
TEXT_COLOR = (255, 255, 255)
SHADOW_COLOR = (0, 0, 0, 150)

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
    else:  # bottom
        start_y = height - overlay_height
        for i in range(overlay_height):
            ratio = i / overlay_height
            alpha = int(200 * ratio)
            color = (*PRIMARY_COLOR, alpha)
            draw.line([(0, start_y + i), (width, start_y + i)], fill=color)
    
    return overlay

def add_text_with_shadow(draw, text, position, font, text_color, shadow_offset=4):
    """Add text with shadow"""
    x, y = position
    # Shadow
    draw.text((x + shadow_offset, y + shadow_offset), text, font=font, fill=(0, 0, 0, 180))
    # Main text
    draw.text((x, y), text, font=font, fill=text_color)

def add_promotional_overlay(img, title, subtitle, position='top', badge_text=None):
    """Add promotional elements to screenshot"""
    width, height = img.size
    
    # Convert to RGBA
    if img.mode != 'RGBA':
        img = img.convert('RGBA')
    
    # Create overlay layer
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    # Load fonts
    try:
        title_font = ImageFont.truetype("arialbd.ttf", 70)
        subtitle_font = ImageFont.truetype("arial.ttf", 45)
        badge_font = ImageFont.truetype("arial.ttf", 35)
    except:
        try:
            title_font = ImageFont.truetype("arial.ttf", 70)
            subtitle_font = ImageFont.truetype("arial.ttf", 45)
            badge_font = ImageFont.truetype("arial.ttf", 35)
        except:
            title_font = ImageFont.load_default()
            subtitle_font = ImageFont.load_default()
            badge_font = ImageFont.load_default()
    
    # Add gradient overlay
    gradient = create_gradient_overlay(width, height, position)
    overlay = Image.alpha_composite(overlay, gradient)
    draw = ImageDraw.Draw(overlay)
    
    # Add text
    if position == 'top':
        title_y = 60
        subtitle_y = 150
        badge_y = height - 180
    else:
        title_y = height - 280
        subtitle_y = height - 190
        badge_y = 80
    
    add_text_with_shadow(draw, title, (50, title_y), title_font, TEXT_COLOR)
    add_text_with_shadow(draw, subtitle, (50, subtitle_y), subtitle_font, TEXT_COLOR)
    
    # Add badge if provided
    if badge_text:
        badge_width = 200
        badge_height = 60
        badge_x = width - badge_width - 50
        
        # Badge background
        draw.rounded_rectangle(
            [badge_x, badge_y, badge_x + badge_width, badge_y + badge_height],
            radius=30,
            fill=(*ACCENT_COLOR, 220)
        )
        
        # Badge text
        bbox = draw.textbbox((0, 0), badge_text, font=badge_font)
        text_width = bbox[2] - bbox[0]
        text_x = badge_x + (badge_width - text_width) // 2
        draw.text((text_x, badge_y + 12), badge_text, font=badge_font, fill=TEXT_COLOR)
    
    # Composite
    result = Image.alpha_composite(img, overlay)
    return result

def add_phone_frame(img):
    """Add modern phone frame"""
    width, height = img.size
    
    # Frame dimensions
    frame_thickness = 25
    corner_radius = 45
    
    # Create frame image
    frame_width = width + (frame_thickness * 2)
    frame_height = height + (frame_thickness * 2) + 80
    
    frame = Image.new('RGBA', (frame_width, frame_height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(frame)
    
    # Phone body (dark gray)
    draw.rounded_rectangle(
        [0, 0, frame_width, frame_height],
        radius=corner_radius,
        fill=(40, 40, 40, 255)
    )
    
    # Screen cutout
    screen_y = 60
    draw.rounded_rectangle(
        [frame_thickness, screen_y + frame_thickness,
         frame_width - frame_thickness, frame_height - frame_thickness],
        radius=corner_radius - 10,
        fill=(0, 0, 0, 255)
    )
    
    # Notch
    notch_width = 180
    notch_height = 25
    notch_x = (frame_width - notch_width) // 2
    draw.rounded_rectangle(
        [notch_x, screen_y, notch_x + notch_width, screen_y + notch_height],
        radius=12,
        fill=(40, 40, 40, 255)
    )
    
    # Paste screenshot
    frame.paste(img, (frame_thickness, screen_y + frame_thickness), img if img.mode == 'RGBA' else None)
    
    # Add shadow
    shadow = Image.new('RGBA', (frame_width + 60, frame_height + 60), (0, 0, 0, 0))
    shadow_draw = ImageDraw.Draw(shadow)
    shadow_draw.rounded_rectangle(
        [15, 15, frame_width + 45, frame_height + 45],
        radius=corner_radius + 10,
        fill=(0, 0, 0, 80)
    )
    shadow = shadow.filter(ImageFilter.GaussianBlur(25))
    
    # Composite
    final = Image.new('RGBA', shadow.size, (255, 255, 255, 255))
    final.paste(shadow, (0, 0), shadow)
    final.paste(frame, (30, 30), frame)
    
    return final

def enhance_colors(img):
    """Enhance screenshot colors"""
    # Slight contrast boost
    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(1.05)
    
    # Slight saturation boost
    enhancer = ImageEnhance.Color(img)
    img = enhancer.enhance(1.1)
    
    # Sharpen
    img = img.filter(ImageFilter.SHARPEN)
    
    return img

def create_feature_graphic():
    """Create feature graphic"""
    width, height = 1024, 500
    
    # Gradient background
    img = Image.new('RGB', (width, height), PRIMARY_COLOR)
    draw = ImageDraw.Draw(img)
    
    for i in range(height):
        ratio = i / height
        r = int(PRIMARY_COLOR[0] * (1 - ratio) + 100 * ratio)
        g = int(PRIMARY_COLOR[1] * (1 - ratio) + 200 * ratio)
        b = int(PRIMARY_COLOR[2] * (1 - ratio) + 255 * ratio)
        draw.line([(0, i), (width, i)], fill=(r, g, b))
    
    # Text
    try:
        title_font = ImageFont.truetype("arialbd.ttf", 100)
        subtitle_font = ImageFont.truetype("arial.ttf", 48)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # Title
    add_text_with_shadow(draw, "Book Reader", (70, 110), title_font, (255, 255, 255), 6)
    add_text_with_shadow(draw, "PDF & EPUB Reader for Android", (70, 240), subtitle_font, (255, 255, 255), 4)
    
    # Decorative elements
    draw.ellipse([800, 100, 950, 250], fill=(*ACCENT_COLOR, 150))
    draw.ellipse([850, 280, 980, 410], fill=(255, 152, 0, 150))
    
    img.save(os.path.join(OUTPUT_FOLDER, "feature_graphic.png"), 'PNG', quality=95)
    print("✅ Created: feature_graphic.png")

def create_app_icon():
    """Create app icon"""
    size = 512
    img = Image.new('RGB', (size, size), PRIMARY_COLOR)
    draw = ImageDraw.Draw(img)
    
    # Gradient
    for i in range(size):
        ratio = i / size
        r = int(PRIMARY_COLOR[0] * (1 - ratio) + 100 * ratio)
        g = int(PRIMARY_COLOR[1] * (1 - ratio) + 200 * ratio)
        b = int(PRIMARY_COLOR[2] * (1 - ratio) + 255 * ratio)
        draw.line([(0, i), (size, i)], fill=(r, g, b))
    
    # Book icon
    try:
        icon_font = ImageFont.truetype("seguiemj.ttf", 280)
    except:
        try:
            icon_font = ImageFont.truetype("arial.ttf", 280)
        except:
            icon_font = ImageFont.load_default()
    
    draw.text((110, 90), "📚", font=icon_font, fill=(255, 255, 255))
    
    # Border
    draw.rectangle([0, 0, size-1, size-1], outline=(255, 255, 255, 200), width=12)
    
    img.save(os.path.join(OUTPUT_FOLDER, "app_icon.png"), 'PNG', quality=95)
    print("✅ Created: app_icon.png")

def main():
    print("=" * 70)
    print("Book Reader - Screenshot Enhancement")
    print("=" * 70)
    print(f"\n📁 Output: {OUTPUT_FOLDER}\n")
    
    print("🎨 Creating promotional screenshots from your app images...\n")
    
    # Note: Since images are provided via chat, we'll create templates
    # User should save their screenshots and run this script
    
    print("📸 To use this script:")
    print("1. Save your 8 screenshots to Desktop/app_screenshots/")
    print("2. Name them: library.png, recent.png, epub_reader.png, etc.")
    print("3. Run this script")
    print("\nFor now, creating feature graphic and app icon...\n")
    
    create_feature_graphic()
    create_app_icon()
    
    print("\n" + "=" * 70)
    print("✅ Graphics created!")
    print(f"📁 Location: {OUTPUT_FOLDER}")
    print("=" * 70)
    print("\n💡 To process your screenshots:")
    print("   Save them to Desktop/app_screenshots/ and run this script again")

if __name__ == "__main__":
    main()
