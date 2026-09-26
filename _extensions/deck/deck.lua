-- Lecture decks. Splits a page into slides at each thematic break (--- on its
-- own line). A slide that contains a level-1 heading is a title slide. The
-- controls and progress bar are added here; deck.js makes them work.

local function has_title(blocks)
  for _, b in ipairs(blocks) do
    if b.t == "Header" and b.level == 1 then return true end
  end
  return false
end

function Pandoc(doc)
  local groups, current = {}, {}
  for _, block in ipairs(doc.blocks) do
    if block.t == "HorizontalRule" then
      if #current > 0 then table.insert(groups, current) end
      current = {}
    else
      table.insert(current, block)
    end
  end
  if #current > 0 then table.insert(groups, current) end

  local total = #groups
  local out = {
    pandoc.RawBlock("html", '<a class="deck-exit" href="index.html">Lecture slides</a>'),
    pandoc.RawBlock("html", '<main class="deck-slides" aria-roledescription="slide deck">'),
  }
  for i, blocks in ipairs(groups) do
    local classes = { "slide" }
    if has_title(blocks) then table.insert(classes, "slide--title") end
    local inner = pandoc.Div(blocks, pandoc.Attr("", { "slide__inner" }))
    table.insert(out, pandoc.Div({ inner }, pandoc.Attr("slide-" .. i, classes,
      { ["aria-roledescription"] = "slide", ["aria-label"] = i .. " of " .. total })))
  end
  table.insert(out, pandoc.RawBlock("html", "</main>"))
  table.insert(out, pandoc.RawBlock("html", [[
<nav class="deck-controls" aria-label="Slide controls">
  <button type="button" data-deck="prev" aria-label="Previous slide">&#8592;</button>
  <span class="deck-count" aria-live="polite"><span data-deck="current">1</span> / ]] .. total .. [[</span>
  <button type="button" data-deck="next" aria-label="Next slide">&#8594;</button>
  <button type="button" data-deck="fullscreen" aria-label="Full screen (F)">&#x26F6;</button>
</nav>
<div class="deck-progress" aria-hidden="true"><span></span></div>]]))
  doc.blocks = out
  return doc
end
