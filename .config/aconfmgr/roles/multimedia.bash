
AddPackage ffmpeg # Complete solution to record, convert and stream audio and video
AddOptionalPackage ffmpeg \
    intel-media-sdk "Intel QuickSync support" `# Legacy API for hardware video acceleration on Intel GPUs (Broadwell to Rocket Lake)` \
    ladspa "LADSPA filters" `#Linux Audio Developer's Simple Plugin API (LADSPA)`
AddPackage untrunc-git # restore a damaged (truncated) mp4, m4v, mov, 3gp video

AddPackage imagemagick # An image viewing/manipulation program
AddPackage kwave # A sound editor
AddPackage inkscape # Professional vector graphics editor
AddOptionalPackage inkscape \
    scour 'optimized SVG output, some extensions' `# An SVG scrubber`
# graphicsmagic -> inkscape
AddOptionalPackage graphicsmagic \
    libwmf 'wmf module' `# A library for reading vector images in Microsoft's native Windows Metafile Format (WMF)`
AddPackage obs-studio # Free, open source software for live streaming and recording
