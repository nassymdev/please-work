Balatro SMODS.Font Tutorial and Examples
This repository provides a comprehensive guide and examples for using SMODS.Font in Balatro mods via the Steamodded framework. SMODS.Font enables the use of custom TrueType fonts (.ttf) for text elements like Joker names, descriptions, tooltips, or localizations, enhancing multilingual support and thematic styling.
Introduction
Balatro's text system supports basic styling, but SMODS.Font (introduced in Steamodded v1.x) allows modders to define and apply custom fonts. Fonts can be referenced by a unique key (e.g., {f:my_custom_font}) or by index (e.g., {f:5} for Balatro's default Noto JP font) in text strings using the {f:} modifier. This integrates with Balatro's text parsing system, making it versatile for modding.
Installation

Install Steamodded: Follow the installation guide at Steamodded GitHub.
Add Your Mod: Place your mod (Lua files and font assets) in the Balatro Mods directory as per Steamodded's instructions.
Add Font Files: Place TrueType font files (.ttf) in your mod's directory (e.g., fonts/ subfolder).
Launch Balatro: Start the game to load the mod and custom fonts.

Usage
Defining a Custom Font
Define a font in your mod's Lua file (e.g., main.lua) using SMODS.Font. The font is registered automatically upon instantiation.
SMODS.Font({
    key = 'custom_font',
    path = 'fonts/custom.ttf',
    render_scale = 200,         -- Base size in pixels (default: 200)
    TEXT_HEIGHT_SCALE = 0.83,   -- Line spacing (default: 0.83)
    TEXT_OFFSET = {x = 0, y = 0}, -- Alignment tweak (default: {0,0})
    FONTSCALE = 0.1,            -- Scale multiplier (default: 0.1)
    squish = 1,                 -- Horizontal stretch (default: 1)
    DESCSCALE = 1               -- Description scale (default: 1)
})

Applying the Font
Use the {f:key_or_index} modifier in any text string that supports Balatro's formatting (e.g., Joker descriptions, tooltips, names). The closing tag {/f} is optional but recommended for resetting.
loc_txt = {
    name = "{f:custom_font}Styled Name",
    text = {
        "Gains {C:money}$#1#{} per round,",
        "{f:5}Default Font Mix{}"  -- Uses Balatro's default font index 5 (Noto JP)
    }
}

Reset to the default font using {} or {f:0} (base font index).
Parameters

key (string, required): Unique identifier for the font (e.g., 'my_custom_font'). Use in {f:} tags.
path (string, required): Relative path to the .ttf file (e.g., 'fonts/myfont.ttf').
render_scale (number, optional, default: 200): Base font size in pixels. Higher values improve quality when scaled.
TEXT_HEIGHT_SCALE (number, optional, default: 0.83): Adjusts line spacing.
TEXT_OFFSET (table {x: number, y: number}, optional, default: {x=0, y=0}): Shifts text for alignment.
FONTSCALE (number, optional, default: 0.1): Scales font size (effective size = render_scale * FONTSCALE).
squish (number, optional, default: 1): Adjusts horizontal character width.
DESCSCALE (number, optional, default: 1): Scales description text (mobile multiplies by 1.5x).

Notes:

Parameters often require trial and error due to LÖVE's font rendering variability.
Only TrueType (.ttf) fonts are supported.
Fonts are stored in SMODS.Fonts and accessible globally after definition.

Applying Fonts in Different Contexts

UI Elements: Use {f:} in parsed text (e.g., tooltips, achievements, SMODS.UI elements).
Localizations: Link a font to a language in SMODS.Language:SMODS.Font({
    key = 'jp_custom_font',
    path = 'fonts/jpfont.ttf',
    render_scale = 200
})

SMODS.Language({
    key = 'jp_custom',
    label = 'Japanese (Custom Font)',
    font = 'jp_custom_font',
    -- Other language params...
})


Custom Rendering: For manual rendering (e.g., with love.graphics.print), access the font via SMODS.Fonts['key'] and set it with love.graphics.setFont().
Non-Parsed Text: Hook into rendering functions using SMODS.inject for unsupported text areas.

Examples
Example 1: Custom Joker with Font
Create a Joker with a custom font for its name and description.
-- Define the font
SMODS.Font({
    key = 'my_custom_font',
    path = 'fonts/myfont.ttf',
    render_scale = 250,
    TEXT_HEIGHT_SCALE = 0.85,
    TEXT_OFFSET = {x = 0, y = -2},
    FONTSCALE = 0.12,
    squish = 0.95,
    DESCSCALE = 1.1
})

-- Define the Joker
SMODS.Joker({
    key = 'custom_joker',
    loc_txt = {
        name = "{f:my_custom_font}Cool Joker Name",
        text = {
            "Gains {C:money}$#1#{} per round,",
            "{f:5}日本語 Bonus Text{}"  -- Uses default font index 5 (Noto JP)
        }
    },
    effect = function(self, args)
        -- Example effect: Add money per round
        G.GAME.dollars = G.GAME.dollars + 1
    end
})

Example 2: Font in Localization
Apply a custom font to a new language.
SMODS.Font({
    key = 'jp_custom_font',
    path = 'fonts/jpfont.ttf',
    render_scale = 200,
    FONTSCALE = 0.11
})

SMODS.Language({
    key = 'jp_custom',
    label = 'Japanese (Custom Font)',
    font = 'jp_custom_font',
    text = {
        joker_name = "{f:jp_custom_font}カスタムジョーカー"
    }
})

Example 3: Inspired by Tangents Mod
The Tangents mod (by Clickseee) credits Aikoyori for SMODS.Font usage. Here's an adapted example for styled text:
-- Define the font
SMODS.Font({
    key = 'fun_font',
    path = 'assets/funfont.ttf',
    render_scale = 180,
    FONTSCALE = 0.11,
    TEXT_OFFSET = {x = 1, y = 0}
})

-- Example Joker
SMODS.Joker({
    key = 'tangent_joker',
    loc_txt = {
        name = "{f:fun_font}Tangent Shenanigans{}",
        text = {
            "Random {f:5}日本語 text{} for fun!",
            "Boosts score by {C:mult}+#1#{}"
        }
    },
    effect = function(self, args)
        -- Example effect: Add mult bonus
        args.mult = args.mult + 5
        return args
    end
})

Tips

Font Files: Place .ttf files in your mod's directory (e.g., fonts/ or assets/).
Debugging: Check the game console for errors (e.g., invalid path or non-TTF files).
Alignment: Adjust TEXT_OFFSET, FONTSCALE, and render_scale for visual alignment.
Mobile: DESCSCALE is scaled by 1.5x on mobile devices.
Resources: Explore Steamodded's example_mods, wiki, or PR #684 for updates.
Community: Join the Balatro Discord (discord.gg/balatro, #modding-chat) for support.

Contributing
Pull requests are welcome! Add examples, fix issues, or improve documentation.
License
Licensed under the GNU General Public License, consistent with Steamodded.
Credits

Inspired by Aikoyori's SMODS.Font contributions (Steamodded PR #684).
Example usage adapted from mods like Tangents.

© 2025 YourRepoName
