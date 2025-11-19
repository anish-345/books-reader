"""
Book Reader App - Real Screenshot Enhancement Tool
Takes actual app screenshots and adds professional promotional overlays
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter, ImageEnhance
import os

# Paths
DESKTOP_PATH = os.path.join(os.path.expanduser("~"), "Desktop")
INPUT_FOLDER = os.path.join(DESKTOP_PATH, "app_screenshots")
OUTPUT_FOLDER = os.path.join(DESKTOP_PATH, "promo")

# Create folders
os.makedirs(INPUT_FOLDER, exist_ok=True)
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# Colors (matching app theme)
PRIMARY_COLOR = (33, 150, 243)  # Blue
ACCENT_COLOR = (255, 152, 0)  # Orange
GRADIENT_START = (33, 150, 243, 220)  # Blue with transparency
GRADIENT_END = (100, 200, 255, 220)  # Light blue with transparency
TEXT_COLOR = (255, 255, 255)  # White
SHADOW_COLOR = (0, 0, 0, 180)  # Black with transparency

def create_gradient_overlay(width, height, color1, color2):
    """Create a gradient overlay with transparency"""
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    for i in range(height):
        ratio = i / height
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        a = int(color1[3] * (1 - ratio) + color2[3] * ratio)
        draw.line([(0, i), (width, i)], fill=(r, g, b, a))
    
    return overlay

def add_text_with_glow(draw, text, position, font, text_color, glow_color):
    """Add text with glow effect"""
    x, y = position
    # Glow layers
    for offset in range(5, 0, -1):
        alpha = int(100 - (offset * 15))
        glow = (*glow_color[:3], alpha)
        draw.text((x + offset, y + offset), text, font=font, fill=glow)
        draw.text((x - offset, y - offset), text, font=font, fill=glow)
    # Main text
    draw.text((x, y), text, font=font, fill=text_color)

def add_phone_frame(img, frame_color=(30, 30, 30)):
    """Add realistic phone frame"""
    width, height = img.size
    frame_width = 30
    corner_radius = 50
    
    # Create frame
    framed_width = width + (frame_width * 2)
    framed_height = height + (frame_width * 2) + 100  # Extra space for notch
    framed = Image.new('RGBA', (framed_width, framed_height), (0, 0, 0, 0))
    
    # Draw phone body
    draw = ImageDraw.Draw(framed)
    draw.rounded_rectangle(
        [0, 0, framed_width, framed_height],
        radius=corner_radius,
        fill=frame_color
    )
    
    # Draw screen area
    screen_y = 50  # Space for notch
    draw.rounded_rectangle(
        [frame_width, screen_y + frame_width, 
         framed_width - frame_width, framed_height - frame_width],
        radius=corner_radius - 10,
        fill=(0, 0, 0)
    )
    
    # Add notch
    notch_width = 200
    notch_height = 30
    notch_x = (framed_width - notch_width) // 2
    draw.rounded_rectangle(
        [notch_x, screen_y, notch_x + notch_width, screen_y + notch_height],
        radius=15,
        fill=frame_color
    )
    
    # Paste screenshot
    framed.paste(img, (frame_width, screen_y + frame_width))
    
    return framed

def add_promotional_overlay(img, title, subtitle, position='top'):
    """Add promotional text overlay"""
    width, height = img.size
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    # Load fonts
    try:
        title_font = ImageFont.truetype("arial.ttf", 90)
        subtitle_font = ImageFont.truetype("arial.ttf", 55)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # Gradient overlay bar
    if position == 'top':
        gradient = create_gradient_overlay(width, 400, GRADIENT_START, GRADIENT_END)
        overlay.paste(gradient, (0, 0), gradient)
        title_y = 80
        subtitle_y = 200
    else:  # bottom
        gradient = create_gradient_overlay(width, 400, GRADIENT_END, GRADIENT_START)
        overlay.paste(gradient, (0, height - 400), gradient)
        title_y = height - 350
        subtitle_y = height - 230
    
    # Add text with glow
    add_text_with_glow(draw, title, (60, title_y), title_font, TEXT_COLOR, SHADOW_COLOR)
    add_text_with_glow(draw, subtitle, (60, subtitle_y), subtitle_font, TEXT_COLOR, SHADOW_COLOR)
    
    # Add decorative elements
    # Corner accent
    accent_size = 100
    if position == 'top':
        draw.ellipse([width - accent_size - 40, 40, width - 40, 40 + accent_size], 
                    fill=(*ACCENT_COLOR, 150))
    else:
        draw.ellipse([40, height - accent_size - 40, 40 + accent_size, height - 40], 
                    fill=(*ACCENT_COLOR, 150))
    
    return overlay

def enhance_screenshot(img):
    """Enhance screenshot colors and sharpness"""
    # Increase contrast slightly
    enhancer = ImageEnhance.Contrast(img)
    img = enhancer.enhance(1.1)
    
    # Increase color saturation
    enhancer = ImageEnhance.Color(img)
    img = enhancer.enhance(1.2)
    
    # Sharpen
    img = img.filter(ImageFilter.SHARPEN)
    
    return img

def add_feature_badges(img, features):
    """Add feature badges to screenshot"""
    width, height = img.size
    overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)
    
    try:
        badge_font = ImageFont.truetype("arial.ttf", 35)
    except:
        badge_font = ImageFont.load_default()
    
    # Position badges at bottom
    y_pos = height - 200
    x_pos = 60
    
    for feature in features:
        # Badge background
        text_bbox = draw.textbbox((0, 0), feature, font=badge_font)
        badge_width = text_bbox[2] - text_bbox[0] + 40
        badge_height = 60
        
        # Draw rounded badge
        draw.rounded_rectangle(
            [x_pos, y_pos, x_pos + badge_width, y_pos + badge_height],
            radius=30,
            fill=(*PRIMARY_COLOR, 200)
        )
        
        # Draw text
        draw.text((x_pos + 20, y_pos + 12), feature, font=badge_font, fill=TEXT_COLOR)
        
        x_pos += badge_width + 20
        if x_pos > width - 200:  # Wrap to next line
            x_pos = 60
            y_pos += 80
    
    return overlay

def process_screenshot(input_path, output_name, title, subtitle, position='top', features=None):
    """Process a single screenshot with enhancements"""
    try:
        # Load screenshot
        img = Image.open(input_path)
        
        # Convert to RGBA
        if img.mode != 'RGBA':
            img = img.convert('RGBA')
        
        # Enhance colors
        img = enhance_screenshot(img)
        
        # Add promotional overlay
        promo_overlay = add_promotional_overlay(img, title, subtitle, position)
        img = Image.alpha_composite(img, promo_overlay)
        
        # Add feature badges if provided
        if features:
            badge_overlay = add_feature_badges(img, features)
            img = Image.alpha_composite(img, badge_overlay)
        
        # Add phone frame
        img = add_phone_frame(img)
        
        # Add shadow effect
        shadow = Image.new('RGBA', (img.width + 40, img.height + 40), (0, 0, 0, 0))
        shadow_draw = ImageDraw.Draw(shadow)
        shadow_draw.rounded_rectangle(
            [10, 10, img.width + 30, img.height + 30],
            radius=60,
            fill=(0, 0, 0, 50)
        )
        shadow = shadow.filter(ImageFilter.GaussianBlur(20))
        
        # Composite
        final = Image.new('RGBA', shadow.size, (255, 255, 255, 0))
        final.paste(shadow, (0, 0), shadow)
        final.paste(img, (20, 20), img)
        
        # Save
        output_path = os.path.join(OUTPUT_FOLDER, output_name)
        final.save(output_path, 'PNG', quality=95)
        print(f"✅ Created: {output_name}")
        return True
        
    except FileNotFoundError:
        print(f"⚠️  Screenshot not found: {input_path}")
        print(f"   Please add this screenshot to: {INPUT_FOLDER}")
        return False
    except Exception as e:
        print(f"❌ Error processing {output_name}: {e}")
        return False

def create_feature_graphic_from_screenshots():
    """Create feature graphic using actual screenshots"""
    width, height = 1024, 500
    
    # Create gradient background
    img = Image.new('RGB', (width, height), PRIMARY_COLOR)
    draw = ImageDraw.Draw(img)
    
    # Gradient
    for i in range(height):
        ratio = i / height
        r = int(PRIMARY_COLOR[0] * (1 - ratio) + 100 * ratio)
        g = int(PRIMARY_COLOR[1] * (1 - ratio) + 200 * ratio)
        b = int(PRIMARY_COLOR[2] * (1 - ratio) + 255 * ratio)
        draw.line([(0, i), (width, i)], fill=(r, g, b))
    
    # Add text
    try:
        title_font = ImageFont.truetype("arial.ttf", 110)
        subtitle_font = ImageFont.truetype("arial.ttf", 50)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # Title with shadow
    shadow_offset = 5
    draw.text((80 + shadow_offset, 120 + shadow_offset), "Book Reader", 
             font=title_font, fill=(0, 0, 0, 100))
    draw.text((80, 120), "Book Reader", font=title_font, fill=(255, 255, 255))
    
    # Subtitle
    draw.text((80 + shadow_offset, 260 + shadow_offset), 
             "Your Ultimate PDF & EPUB Reader", 
             font=subtitle_font, fill=(0, 0, 0, 100))
    draw.text((80, 260), "Your Ultimate PDF & EPUB Reader", 
             font=subtitle_font, fill=(255, 255, 255))
    
    # Add decorative circles
    for i, (x, y) in enumerate([(850, 150), (920, 250), (790, 350)]):
        alpha = 150 - (i * 30)
        circle_img = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        circle_draw = ImageDraw.Draw(circle_img)
        circle_draw.ellipse([x, y, x + 100, y + 100], fill=(*ACCENT_COLOR, alpha))
        img = Image.alpha_composite(img.convert('RGBA'), circle_img)
    
    # Save
    output_path = os.path.join(OUTPUT_FOLDER, "feature_graphic.png")
    img.convert('RGB').save(output_path, 'PNG', quality=95)
    print("✅ Created: feature_graphic.png")

def create_app_icon():
    """Create high-res app icon"""
    size = 512
    img = Image.new('RGB', (size, size), PRIMARY_COLOR)
    draw = ImageDraw.Draw(img)
    
    # Gradient background
    for i in range(size):
        ratio = i / size
        r = int(PRIMARY_COLOR[0] * (1 - ratio) + 100 * ratio)
        g = int(PRIMARY_COLOR[1] * (1 - ratio) + 200 * ratio)
        b = int(PRIMARY_COLOR[2] * (1 - ratio) + 255 * ratio)
        draw.line([(0, i), (size, i)], fill=(r, g, b))
    
    # Book icon
    try:
        icon_font = ImageFont.truetype("seguiemj.ttf", 300)  # Emoji font
    except:
        try:
            icon_font = ImageFont.truetype("arial.ttf", 300)
        except:
            icon_font = ImageFont.load_default()
    
    # Draw book emoji or text
    draw.text((100, 80), "📚", font=icon_font, fill=(255, 255, 255))
    
    # Add border
    draw.rectangle([0, 0, size-1, size-1], outline=(255, 255, 255), width=15)
    
    # Save
    output_path = os.path.join(OUTPUT_FOLDER, "app_icon.png")
    img.save(output_path, 'PNG', quality=95)
    print("✅ Created: app_icon.png")

def main():
    print("=" * 70)
    print("Book Reader - Real Screenshot Enhancement Tool")
    print("=" * 70)
    print(f"\n📁 Input folder: {INPUT_FOLDER}")
    print(f"📁 Output folder: {OUTPUT_FOLDER}\n")
    
    print("📸 STEP 1: Take Screenshots from Your App")
    print("-" * 70)
    print("Please take the following screenshots from your app:")
    print("  1. home_screen.png - Home screen with book list")
    print("  2. pdf_reader.png - PDF reading screen")
    print("  3. epub_reader.png - EPUB reading screen")
    print("  4. bookmarks.png - Bookmarks or progress screen")
    print("  5. settings.png - Settings or features screen (optional)")
    print(f"\nSave them to: {INPUT_FOLDER}")
    print("\nHow to take screenshots:")
    print("  • Android: Press Power + Volume Down")
    print("  • Transfer to PC via USB or cloud")
    print("  • Rename files as shown above")
    print("\n" + "=" * 70)
    
    input("\nPress Enter when screenshots are ready...")
    
    print("\n🎨 STEP 2: Processing Screenshots")
    print("-" * 70)
    
    # Process each screenshot
    screenshots = [
        ("home_screen.png", "01_home_screen_promo.png", 
         "Your Digital Library", "All Books in One Place", "top", ["📚 PDF", "📖 EPUB"]),
        
        ("pdf_reader.png", "02_pdf_reader_promo.png",
         "Smooth PDF Reading", "Zoom, Navigate & Bookmark", "bottom", ["🔍 Zoom", "🔖 Bookmark"]),
        
        ("epub_reader.png", "03_epub_reader_promo.png",
         "Immersive Reading", "Chapter Navigation & Progress", "top", ["📊 Progress", "📑 Chapters"]),
        
        ("bookmarks.png", "04_bookmarks_promo.png",
         "Never Lose Your Place", "Automatic Progress Tracking", "bottom", ["⭐ Bookmarks", "📈 Stats"]),
        
        ("settings.png", "05_features_promo.png",
         "Powerful Features", "Fast, Private & Reliable", "top", ["🚀 Fast", "🔒 Private"]),
    ]
    
    success_count = 0
    for input_name, output_name, title, subtitle, position, features in screenshots:
        input_path = os.path.join(INPUT_FOLDER, input_name)
        if process_screenshot(input_path, output_name, title, subtitle, position, features):
            success_count += 1
    
    print(f"\n✅ Successfully processed {success_count} screenshots")
    
    # Create additional graphics
    print("\n🎨 Creating Additional Graphics")
    print("-" * 70)
    create_feature_graphic_from_screenshots()
    create_app_icon()
    
    print("\n" + "=" * 70)
    print("✅ All promotional materials created!")
    print(f"📁 Location: {OUTPUT_FOLDER}")
    print("=" * 70)
    print("\n✨ Your screenshots are now ready for Softonic submission!")
    print("\nNext steps:")
    print("  1. Review images in Desktop/promo/")
    print("  2. Follow SOFTONIC_SUBMISSION_GUIDE.md")
    print("  3. Upload to Softonic Publisher")

if __name__ == "__main__":
    main()
