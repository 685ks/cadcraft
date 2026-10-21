//! Embeds the fonts of the optional craft-fonts build input (`CRAFT_FONTS_DIR`) as `CRAFT_FONTS`,
//! through `craft-fonts-build` (685ks/craft-fonts). Unset or empty, `CRAFT_FONTS` is empty and the
//! build is unchanged. It only reads the local checkout (no network). A bad checkout is a
//! warning, or an error with `CRAFT_FONTS_REQUIRED=1`.
//!
//! On wasm32 it embeds only BIZ UDPGothic Regular and the Arabic face (about 5.5 MB), to keep the
//! web build within hosting limits (Cloudflare Pages: 25 MiB per file). The web build has no
//! system fonts, so these are its only fallback for Japanese and Arabic-script text.

/// Family-name prefixes AGENTS.md bars (no Adobe fonts, ever): Adobe's Source families and the
/// Noto CJK faces, which are Source Han under another name (also as the regional `Noto Sans KR` /
/// `TC` cuts). `src/craft_fonts.rs` tests the same list.
const BARRED_FAMILIES: [&str; 7] = ["Source Han", "Source Serif", "Source Sans", "Noto Sans CJK", "Noto Serif CJK", "Noto Sans KR", "Noto Sans TC"];

fn main() {
    craft_fonts_build::Builder::new()
        .legacy(true)
        .web_fonts(&[("BIZ UDPGothic", "Regular"), ("Noto Sans Arabic", "Regular")])
        .include(|e| {
            if BARRED_FAMILIES.iter().any(|barred| e.family.starts_with(barred)) {
                println!("cargo::warning=craft-fonts: not embedding {} {} (AGENTS.md: no Adobe fonts)", e.family, e.style);
                return false;
            }
            // Colour emoji has no outlines for the text renderer to draw.
            !e.family.contains("Emoji")
        })
        .emit();
}
