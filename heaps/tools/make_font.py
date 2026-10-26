"""Writes res/font/bold.fnt and bold.png: a BMFont (text format) of DejaVu Sans Bold, the font
Java draws for "Dialog" bold on Linux. Run from the heaps folder: python3 tools/make_font.py"""
import os
from PIL import Image, ImageDraw, ImageFont

SIZE = 64
TTF = "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
CHARS = [c for c in range(32, 127)] + [c for c in range(160, 256)]
PAD = 2
WIDTH = 1024

font = ImageFont.truetype(TTF, SIZE)
ascent, descent = font.getmetrics()
glyphs = []
x = y = PAD
row = 0
for c in CHARS:
	ch = chr(c)
	l, t, r, b = font.getbbox(ch)
	w, h = max(r - l, 0), max(b - t, 0)
	if x + w + PAD > WIDTH:
		x = PAD
		y += row + PAD
		row = 0
	glyphs.append((c, x, y, w, h, l, t, round(font.getlength(ch))))
	x += w + PAD
	row = max(row, h)
height = 1
while height < y + row + PAD:
	height *= 2

img = Image.new("RGBA", (WIDTH, height), (255, 255, 255, 0))
draw = ImageDraw.Draw(img)
for c, gx, gy, w, h, l, t, adv in glyphs:
	if w > 0 and h > 0:
		draw.text((gx - l, gy - t), chr(c), font=font, fill=(255, 255, 255, 255))

out = "res/font"
os.makedirs(out, exist_ok=True)
img.save(os.path.join(out, "bold.png"))
with open(os.path.join(out, "bold.fnt"), "w") as f:
	f.write(f'info face="DejaVu Sans Bold" size={SIZE} bold=1 italic=0 charset="" unicode=1 stretchH=100 smooth=1 aa=1 padding=0,0,0,0 spacing=0,0\n')
	f.write(f"common lineHeight={ascent + descent} base={ascent} scaleW={WIDTH} scaleH={height} pages=1 packed=0\n")
	f.write('page id=0 file="bold.png"\n')
	f.write(f"chars count={len(glyphs)}\n")
	for c, gx, gy, w, h, l, t, adv in glyphs:
		f.write(f"char id={c} x={gx} y={gy} width={w} height={h} xoffset={l} yoffset={t} xadvance={adv} page=0 chnl=15\n")
