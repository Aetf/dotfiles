# Fonts
AddPackage noto-fonts-cjk # Google Noto CJK fonts
AddPackage noto-fonts-emoji # Google Noto emoji fonts
AddPackage noto-fonts-extra # Google Noto TTF fonts - additional variants

# A basic coding font with icons before we have ComicCode setup
AddPackage $FOREIGN ttf-nerd-fonts-hack-complete-git # Patched font Hack from nerd-fonts library

# Setup common Windows font alias
AddPackage ttf-croscore # Metric-compatible fonts for Helvetica, Times, Courier and Georgia — named Arimo, Tinos, Cousine and Gelasio respectively, shipped with Chrome OS
CreateLink /etc/fonts/conf.d/30-metric-aliases.conf /usr/share/fontconfig/conf.avail/30-metric-aliases.conf


# Fallback to Noto CJK font when glyphs are missing
CopyFile /etc/fonts/conf.d/50-cjk-sc.conf
