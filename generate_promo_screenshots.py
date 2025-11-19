"""
Book Reader App - Promotional Screenshot Generator
Generates professional app store screenshots using Pillow
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import os

# Create output directory
DESKTOP_PATH = os.path.join(os.path.expanduser("~"), "Desktop", "promo")
os.makedirs(DESKTOP_PATH, exist_ok=True)

# Screenshot dimensions (standard Android phone)
WIDTH = 1080
HEIGHT = 1920

# Colors (matching app theme)
PRIMARY_COLOR = (33, 150, 243)  # Blue
BACKGROUND_COLOR = (250, 250, 250)  # Light gray
TEXT_COLOR = (33, 33, 33)  # Dark gray
ACCENT_COLOR = (255, 152, 0)  # Orange
WHITE = (255, 255, 255)

def create_gradient_background(width, height, color1, color2):
    """Create a gradient background"""
    base = Image.new('RGB', (width, height), color1)
    draw = ImageDraw.Draw(base)
    
    for i in range(height):
        ratio = i / height
        r = int(color1[0] * (1 - ratio) + color2[0] * ratio)
        g = int(color1[1] * (1 - ratio) + color2[1] * ratio)
        b = int(color1[2] * (1 - ratio) + color2[2] * ratio)
        draw.line([(0, i), (width, i)], fill=(r, g, b))
    
    return base

def add_phone_frame(img):
    """Add a phone frame around the screenshot"""
    frame_width = 40
    frame_color = (50, 50, 50)
    
    # Create new image with frame
    framed = Image.new('RGB', (WIDTH + frame_width * 2, HEIGHT + frame_width * 2), frame_color)
    framed.paste(img, (frame_width, frame_width))
    
    # Add rounded corners effect
    draw = ImageDraw.Draw(framed)
    corner_radius = 60
    
    return framed

def create_text_with_shadow(draw, text, position, font, text_color, shadow_color):
    """Draw text with shadow effect"""
    x, y = position
    # Shadow
    draw.text((x + 3, y + 3), text, font=font, fill=shadow_color)
    # Main text
    draw.text((x, y), text, font=font, fill=text_color)

# Screenshot 1: Home Screen with Book Library
def generate_screenshot_1():
    print("Generating Screenshot 1: Home Screen...")
    
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND_COLOR)
    draw = ImageDraw.Draw(img)
    
    # Try to load fonts, fallback to default
    try:
        title_font = ImageFont.truetype("arial.ttf", 80)
        subtitle_font = ImageFont.truetype("arial.ttf", 50)
        text_font = ImageFont.truetype("arial.ttf", 40)
        small_font = ImageFont.truetype("arial.ttf", 30)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Header
    draw.rectangle([0, 0, WIDTH, 200], fill=PRIMARY_COLOR)
    create_text_with_shadow(draw, "Book Reader", (60, 70), title_font, WHITE, (0, 0, 0, 128))
    
    # Search bar
    draw.rounded_rectangle([60, 240, WIDTH-60, 340], radius=20, fill=WHITE)
    draw.text((100, 270), "🔍 Search books...", font=text_font, fill=(150, 150, 150))
    
    # Book cards
    y_offset = 400
    books = [
        ("📕 The Great Novel", "John Doe", "2.5 MB"),
        ("📘 Science Guide", "Jane Smith", "5.2 MB"),
        ("📗 History Book", "Bob Wilson", "3.8 MB"),
        ("📙 Math Textbook", "Alice Brown", "4.1 MB"),
    ]
    
    for title, author, size in books:
        # Card background
        draw.rounded_rectangle([60, y_offset, WIDTH-60, y_offset+140], radius=15, fill=WHITE)
        
        # Book icon and info
        draw.text((100, y_offset+20), title, font=text_font, fill=TEXT_COLOR)
        draw.text((100, y_offset+70), f"By {author}", font=small_font, fill=(120, 120, 120))
        draw.text((100, y_offset+105), f"📄 {size}", font=small_font, fill=(120, 120, 120))
        
        y_offset += 170
    
    # Bottom navigation
    draw.rectangle([0, HEIGHT-150, WIDTH, HEIGHT], fill=WHITE)
    nav_items = ["📚 Library", "📖 Recent", "⭐ Favorites"]
    nav_x = 150
    for item in nav_items:
        draw.text((nav_x, HEIGHT-100), item, font=small_font, fill=PRIMARY_COLOR)
        nav_x += 300
    
    # Add promotional text
    promo_bg = Image.new('RGBA', (WIDTH, 300), (0, 0, 0, 180))
    img.paste(promo_bg, (0, 100), promo_bg)
    create_text_with_shadow(draw, "Your Digital Library", (80, 150), subtitle_font, WHITE, (0, 0, 0))
    create_text_with_shadow(draw, "All Your Books in One Place", (80, 220), text_font, (200, 200, 200), (0, 0, 0))
    
    img.save(os.path.join(DESKTOP_PATH, "01_home_screen.png"))
    print("✅ Screenshot 1 saved!")

# Screenshot 2: PDF Reader
def generate_screenshot_2():
    print("Generating Screenshot 2: PDF Reader...")
    
    img = Image.new('RGB', (WIDTH, HEIGHT), WHITE)
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 80)
        subtitle_font = ImageFont.truetype("arial.ttf", 50)
        text_font = ImageFont.truetype("arial.ttf", 40)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
    
    # Top bar
    draw.rectangle([0, 0, WIDTH, 150], fill=PRIMARY_COLOR)
    draw.text((60, 50), "📄 Document.pdf", font=text_font, fill=WHITE)
    
    # PDF content simulation
    draw.rectangle([100, 200, WIDTH-100, HEIGHT-300], fill=(240, 240, 240), outline=(200, 200, 200), width=3)
    
    # Simulate text lines
    for i in range(15):
        y = 250 + i * 60
        line_width = 800 if i % 3 != 0 else 600
        draw.rectangle([150, y, 150 + line_width, y + 30], fill=(180, 180, 180))
    
    # Bottom controls
    draw.rectangle([0, HEIGHT-250, WIDTH, HEIGHT], fill=WHITE)
    
    # Page indicator
    draw.rounded_rectangle([WIDTH//2-150, HEIGHT-220, WIDTH//2+150, HEIGHT-160], radius=20, fill=PRIMARY_COLOR)
    draw.text((WIDTH//2-100, HEIGHT-205), "Page 5 / 120", font=text_font, fill=WHITE)
    
    # Control buttons
    controls = ["⬅️", "🔖", "🔍", "➡️"]
    x_pos = 150
    for control in controls:
        draw.ellipse([x_pos, HEIGHT-130, x_pos+100, HEIGHT-30], fill=PRIMARY_COLOR)
        draw.text((x_pos+25, HEIGHT-105), control, font=subtitle_font, fill=WHITE)
        x_pos += 220
    
    # Promotional overlay
    promo_bg = Image.new('RGBA', (WIDTH, 250), (0, 0, 0, 180))
    img.paste(promo_bg, (0, 600), promo_bg)
    create_text_with_shadow(draw, "Smooth PDF Reading", (100, 650), subtitle_font, WHITE, (0, 0, 0))
    create_text_with_shadow(draw, "Zoom, Navigate & Bookmark", (100, 720), text_font, (200, 200, 200), (0, 0, 0))
    
    img.save(os.path.join(DESKTOP_PATH, "02_pdf_reader.png"))
    print("✅ Screenshot 2 saved!")

# Screenshot 3: EPUB Reader
def generate_screenshot_3():
    print("Generating Screenshot 3: EPUB Reader...")
    
    img = Image.new('RGB', (WIDTH, HEIGHT), (255, 250, 240))  # Warm reading background
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 80)
        subtitle_font = ImageFont.truetype("arial.ttf", 50)
        text_font = ImageFont.truetype("arial.ttf", 40)
        book_font = ImageFont.truetype("arial.ttf", 45)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
        book_font = ImageFont.load_default()
    
    # Top bar
    draw.rectangle([0, 0, WIDTH, 150], fill=PRIMARY_COLOR)
    draw.text((60, 50), "📖 Novel.epub", font=text_font, fill=WHITE)
    
    # Book content area
    content_margin = 120
    draw.rectangle([content_margin, 200, WIDTH-content_margin, HEIGHT-200], fill=WHITE)
    
    # Chapter title
    draw.text((content_margin+40, 250), "Chapter 5: The Journey", font=subtitle_font, fill=TEXT_COLOR)
    
    # Simulate book text
    book_text = [
        "The sun was setting over the",
        "horizon as she walked along",
        "the beach. The waves crashed",
        "gently against the shore,",
        "creating a soothing rhythm",
        "that matched her thoughts.",
        "",
        "She had been walking for",
        "hours, lost in contemplation",
        "about the events of the day.",
    ]
    
    y_text = 350
    for line in book_text:
        draw.text((content_margin+40, y_text), line, font=book_font, fill=TEXT_COLOR)
        y_text += 70
    
    # Progress bar
    draw.rectangle([content_margin, HEIGHT-180, WIDTH-content_margin, HEIGHT-160], fill=(220, 220, 220))
    draw.rectangle([content_margin, HEIGHT-180, content_margin+600, HEIGHT-160], fill=ACCENT_COLOR)
    draw.text((WIDTH//2-80, HEIGHT-150), "45% Complete", font=text_font, fill=TEXT_COLOR)
    
    # Promotional overlay
    promo_bg = Image.new('RGBA', (WIDTH, 250), (0, 0, 0, 180))
    img.paste(promo_bg, (0, 900), promo_bg)
    create_text_with_shadow(draw, "Immersive EPUB Reading", (100, 950), subtitle_font, WHITE, (0, 0, 0))
    create_text_with_shadow(draw, "Track Progress & Chapters", (100, 1020), text_font, (200, 200, 200), (0, 0, 0))
    
    img.save(os.path.join(DESKTOP_PATH, "03_epub_reader.png"))
    print("✅ Screenshot 3 saved!")

# Screenshot 4: Features Highlight
def generate_screenshot_4():
    print("Generating Screenshot 4: Features...")
    
    # Gradient background
    img = create_gradient_background(WIDTH, HEIGHT, PRIMARY_COLOR, (100, 200, 255))
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 90)
        subtitle_font = ImageFont.truetype("arial.ttf", 55)
        text_font = ImageFont.truetype("arial.ttf", 45)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
    
    # Title
    create_text_with_shadow(draw, "Powerful Features", (100, 150), title_font, WHITE, (0, 0, 0))
    
    # Feature cards
    features = [
        ("📚", "Multi-Format", "PDF & EPUB Support"),
        ("🔖", "Bookmarks", "Save Your Place"),
        ("📊", "Progress", "Track Reading"),
        ("🚀", "Fast", "Optimized Performance"),
        ("🎨", "Clean UI", "Beautiful Design"),
        ("🔒", "Private", "Local Storage"),
    ]
    
    y_offset = 350
    for i in range(0, len(features), 2):
        x_offset = 100
        for j in range(2):
            if i + j < len(features):
                emoji, title, desc = features[i + j]
                
                # Card
                draw.rounded_rectangle([x_offset, y_offset, x_offset+400, y_offset+200], 
                                      radius=20, fill=WHITE)
                
                # Content
                draw.text((x_offset+150, y_offset+30), emoji, font=title_font, fill=PRIMARY_COLOR)
                draw.text((x_offset+50, y_offset+120), title, font=subtitle_font, fill=TEXT_COLOR)
                draw.text((x_offset+50, y_offset+160), desc, font=text_font, fill=(120, 120, 120))
                
                x_offset += 480
        
        y_offset += 250
    
    # Bottom CTA
    draw.rounded_rectangle([150, HEIGHT-250, WIDTH-150, HEIGHT-150], radius=30, fill=ACCENT_COLOR)
    create_text_with_shadow(draw, "Download Now!", (WIDTH//2-200, HEIGHT-220), subtitle_font, WHITE, (0, 0, 0))
    
    img.save(os.path.join(DESKTOP_PATH, "04_features.png"))
    print("✅ Screenshot 4 saved!")

# Screenshot 5: Reading Progress & Bookmarks
def generate_screenshot_5():
    print("Generating Screenshot 5: Progress & Bookmarks...")
    
    img = Image.new('RGB', (WIDTH, HEIGHT), BACKGROUND_COLOR)
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 80)
        subtitle_font = ImageFont.truetype("arial.ttf", 50)
        text_font = ImageFont.truetype("arial.ttf", 40)
        small_font = ImageFont.truetype("arial.ttf", 35)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        text_font = ImageFont.load_default()
        small_font = ImageFont.load_default()
    
    # Header
    draw.rectangle([0, 0, WIDTH, 200], fill=PRIMARY_COLOR)
    create_text_with_shadow(draw, "Your Progress", (60, 70), title_font, WHITE, (0, 0, 0))
    
    # Stats cards
    stats = [
        ("📚", "12", "Books Read"),
        ("⏱️", "24h", "Reading Time"),
        ("🔖", "45", "Bookmarks"),
    ]
    
    y_pos = 250
    for emoji, value, label in stats:
        draw.rounded_rectangle([60, y_pos, WIDTH-60, y_pos+150], radius=15, fill=WHITE)
        draw.text((100, y_pos+20), emoji, font=title_font, fill=PRIMARY_COLOR)
        draw.text((250, y_pos+30), value, font=subtitle_font, fill=TEXT_COLOR)
        draw.text((250, y_pos+90), label, font=text_font, fill=(120, 120, 120))
        y_pos += 180
    
    # Recent bookmarks
    draw.text((60, y_pos+30), "Recent Bookmarks", font=subtitle_font, fill=TEXT_COLOR)
    y_pos += 100
    
    bookmarks = [
        ("Chapter 3: The Beginning", "Page 45"),
        ("Important Section", "Page 78"),
        ("Key Concepts", "Page 112"),
    ]
    
    for title, page in bookmarks:
        draw.rounded_rectangle([60, y_pos, WIDTH-60, y_pos+100], radius=10, fill=WHITE)
        draw.text((100, y_pos+20), "🔖", font=text_font, fill=ACCENT_COLOR)
        draw.text((180, y_pos+20), title, font=text_font, fill=TEXT_COLOR)
        draw.text((180, y_pos+60), page, font=small_font, fill=(120, 120, 120))
        y_pos += 120
    
    # Promotional overlay
    promo_bg = Image.new('RGBA', (WIDTH, 250), (0, 0, 0, 180))
    img.paste(promo_bg, (0, 200), promo_bg)
    create_text_with_shadow(draw, "Never Lose Your Place", (100, 250), subtitle_font, WHITE, (0, 0, 0))
    create_text_with_shadow(draw, "Automatic Progress Tracking", (100, 320), text_font, (200, 200, 200), (0, 0, 0))
    
    img.save(os.path.join(DESKTOP_PATH, "05_progress_bookmarks.png"))
    print("✅ Screenshot 5 saved!")

# Feature graphic (1024x500 for app stores)
def generate_feature_graphic():
    print("Generating Feature Graphic...")
    
    width, height = 1024, 500
    img = create_gradient_background(width, height, PRIMARY_COLOR, (100, 200, 255))
    draw = ImageDraw.Draw(img)
    
    try:
        title_font = ImageFont.truetype("arial.ttf", 100)
        subtitle_font = ImageFont.truetype("arial.ttf", 50)
    except:
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
    
    # Main text
    create_text_with_shadow(draw, "Book Reader", (80, 120), title_font, WHITE, (0, 0, 0))
    create_text_with_shadow(draw, "Your Ultimate PDF & EPUB Reader", (80, 250), subtitle_font, WHITE, (0, 0, 0))
    
    # Icons
    icons = ["📚", "📖", "🔖", "🚀"]
    x_pos = 650
    for icon in icons:
        draw.text((x_pos, 180), icon, font=title_font, fill=WHITE)
        x_pos += 90
    
    img.save(os.path.join(DESKTOP_PATH, "feature_graphic.png"))
    print("✅ Feature graphic saved!")

# App icon (512x512)
def generate_app_icon():
    print("Generating App Icon...")
    
    size = 512
    img = Image.new('RGB', (size, size), PRIMARY_COLOR)
    draw = ImageDraw.Draw(img)
    
    try:
        icon_font = ImageFont.truetype("arial.ttf", 280)
    except:
        icon_font = ImageFont.load_default()
    
    # Book emoji
    draw.text((120, 80), "📚", font=icon_font, fill=WHITE)
    
    # Border
    draw.rectangle([0, 0, size-1, size-1], outline=WHITE, width=10)
    
    img.save(os.path.join(DESKTOP_PATH, "app_icon.png"))
    print("✅ App icon saved!")

# Main execution
def main():
    print("=" * 60)
    print("Book Reader - Promotional Screenshot Generator")
    print("=" * 60)
    print(f"\nOutput directory: {DESKTOP_PATH}\n")
    
    generate_screenshot_1()
    generate_screenshot_2()
    generate_screenshot_3()
    generate_screenshot_4()
    generate_screenshot_5()
    generate_feature_graphic()
    generate_app_icon()
    
    print("\n" + "=" * 60)
    print("✅ All promotional materials generated successfully!")
    print(f"📁 Location: {DESKTOP_PATH}")
    print("=" * 60)
    print("\nGenerated files:")
    print("  • 01_home_screen.png - Home screen with book library")
    print("  • 02_pdf_reader.png - PDF reading interface")
    print("  • 03_epub_reader.png - EPUB reading experience")
    print("  • 04_features.png - Feature highlights")
    print("  • 05_progress_bookmarks.png - Progress tracking")
    print("  • feature_graphic.png - App store feature graphic")
    print("  • app_icon.png - High-res app icon")
    print("\n✨ Ready for Softonic submission!")

if __name__ == "__main__":
    main()
