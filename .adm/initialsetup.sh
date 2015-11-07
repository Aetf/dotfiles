#! /bin/sh
infocmp -A /usr/share/terminfo linux > linux
patch -lp1 <<EOF
--- a/linux
+++ b/linux
@@ -4,7 +4,7 @@ linux|linux console,
    colors#8, it#8, ncv#18, pairs#64,
    acsc=+\020\,\021-\030.^Y0\333\`\004a\261f\370g\361h\260i\316j\331k\277l\332m\300n\305o~p\304q\304r\304s_t\303u\264v\301w\302x\263y\363z\362{\343|\330}\234~\376,
    bel=^G, blink=\E[5m, bold=\E[1m, civis=\E[?25l\E[?1c,
-   clear=\E[H\E[J, cnorm=\E[?25h\E[?0c, cr=^M,
+   clear=\E[H\E[J, cnorm=\E[?25h\E[?16;16;240c, cr=^M,
    csr=\E[%i%p1%d;%p2%dr, cub=\E[%p1%dD, cub1=^H,
    cud=\E[%p1%dB, cud1=^J, cuf=\E[%p1%dC, cuf1=\E[C,
    cup=\E[%i%p1%d;%p2%dH, cuu=\E[%p1%dA, cuu1=\E[A,
EOF
tic linux
rm linux
