# Fonts
AddPackage noto-fonts-cjk # Google Noto CJK fonts
AddPackage noto-fonts-emoji # Google Noto emoji fonts
AddPackage noto-fonts-extra # Google Noto TTF fonts - additional variants

# A basic coding font with icons before we have ComicCode setup
AddPackage $FOREIGN ttf-nerd-fonts-hack-complete-git # Patched font Hack from nerd-fonts library

# Fallback to Noto CJK font when glyphs are missing
CopyFile /etc/fonts/conf.d/50-cjk-sc.conf
