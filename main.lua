function love.load()
  tilesize = 100 -- pixels
  gridsize = 6 -- tiles
  margin = 10 -- pixels

  black = {0, 0, 0, 255}
  white = {255, 255, 255, 255}
  yellow = {255, 255, 0, 255}
  grey = {105, 105, 105, 255}
  aquamarine = {127, 255, 212, 255}

  -- FIXME: start / end at other positions
  startx = 2
  starty = 1
  endx = gridsize
  endy = gridsize

  flowamt = 0 -- in tiles (fractional)
  flowspeed = 0.005 -- in tiles / second

  whatfont = love.graphics.newFont(48)
  love.graphics.setFont(whatfont)
  fontheight = whatfont:getHeight()
  fontwhatwidth = whatfont:getWidth('?')

  swapfont = love.graphics.newFont(32)
  swapheight = swapfont:getHeight()
  swapwidth = swapfont:getWidth('swap')

  BLOCKED = 0
  LEFT = 1
  RIGHT = 2
  DOWN = 3
  UP = 4

  function connector(a, b)
    return function(direction)
      if direction == a then return b end
      if direction == b then return a end
      return BLOCKED
    end
  end

  HORIZONTAL = connector(LEFT, RIGHT)
  VERTICAL = connector(UP, DOWN)
  LEFTUP = connector(LEFT, UP)
  LEFTDOWN = connector(LEFT, DOWN)
  RIGHTUP = connector(RIGHT, UP)
  RIGHTDOWN = connector(RIGHT, DOWN)
  PIPES = {HORIZONTAL, VERTICAL, LEFTUP, LEFTDOWN, RIGHTUP, RIGHTDOWN}

  x = 1
  y = 1

  love.window.setMode(
    tilesize * gridsize + margin * 3 + tilesize,
    tilesize * gridsize + margin * 2
  )

  math.randomseed(os.time())

  grid = {}
  for i = 1, gridsize do
    grid[i] = {}
    for j = 1, gridsize do
      grid[i][j] = {hidden = true, kind = PIPES[math.random(1, #PIPES)]}
    end
  end

  swap = {hidden = false, kind = PIPES[math.random(1, #PIPES)]}

  grid[startx][starty] = {hidden = false, kind = VERTICAL}
end

function love.keypressed(key)
  if key == 'left' then
    x = math.max(x - 1, 1)
  elseif key == 'right' then
    x = math.min(x + 1, gridsize)
  elseif key == 'down' then
    y = math.min(y + 1, gridsize)
  elseif key == 'up' then
    y = math.max(y - 1, 1)
  elseif key == 'space' then
    if grid[x][y].hidden then
      grid[x][y].hidden = false
    else
      local tmp = swap.kind
      swap.kind = grid[x][y].kind
      grid[x][y].kind = tmp
    end
  end
end

function pixels(i)
  size = margin + (i - 1) * tilesize
  -- FIXME hack
  if i > gridsize then
    size = size + margin
  end
  return size
end

function printcentered(text, xpos, ypos)
  font = love.graphics.getFont()
  width = font:getWidth(text)
  height = font:getHeight()
  love.graphics.print(
    text,
    xpos + (tilesize - width) / 2,
    ypos + (tilesize - height) / 2
  )
end

function drawtile(tile, i, j)
  xpos = pixels(i)
  ypos = pixels(j)

  smallr = tilesize / 4
  bigr = 3 * tilesize / 4

  if tile.hidden then
    love.graphics.setColor(white)
    printcentered('?', xpos, ypos)
  elseif tile.kind == HORIZONTAL then
    love.graphics.setColor(grey)
    love.graphics.rectangle(
      'fill', xpos, ypos + (tilesize / 4), tilesize, tilesize / 2)
    -- love.graphics.setColor(aquamarine)
    -- love.graphics.rectangle(
    --   'fill', xpos, ypos + (tilesize / 4), tilesize * flowamt, tilesize / 2)
  elseif tile.kind == VERTICAL then
    love.graphics.setColor(grey)
    love.graphics.rectangle(
      'fill', xpos + (tilesize / 4), ypos, tilesize / 2, tilesize)
    -- love.graphics.setColor(aquamarine)
    -- love.graphics.rectangle(
    --   'fill', xpos + (tilesize / 4), ypos, tilesize / 2, tilesize * flowamt)
  else
    if tile.kind == LEFTUP then
      centerx = xpos
      centery = ypos
      angfrom = 0
      argto = math.pi / 2
    elseif tile.kind == LEFTDOWN then
      centerx = xpos
      centery = ypos + tilesize
      angfrom = 3 * math.pi / 2
      argto = 2 * math.pi
    elseif tile.kind == RIGHTUP then
      centerx = xpos + tilesize
      centery = ypos
      angfrom = math.pi / 2
      argto = math.pi
    elseif tile.kind == RIGHTDOWN then
      centerx = xpos + tilesize
      centery = ypos + tilesize
      angfrom = math.pi
      argto = 3 * math.pi / 2
    end
    love.graphics.setColor(grey)
    love.graphics.arc('fill', centerx, centery, bigr, angfrom, argto)
    -- love.graphics.setColor(aquamarine)
    -- love.graphics.arc(
    --   'fill', centerx, centery, bigr,
    --   angfrom, angfrom + (argto - angfrom) * flowamt)
    love.graphics.setColor(black)
    love.graphics.arc('fill', centerx, centery, smallr, angfrom, argto)
  end

  love.graphics.setColor(white)
  love.graphics.rectangle('line',  xpos, ypos, tilesize, tilesize)
end

function love.update(dt)
  flowamt = flowamt + flowspeed
  if flowamt >= 1 then
    flowamt = 0
  end
end

function love.draw()
  love.graphics.setColor(black)
  love.graphics.clear()

  for i = 1, gridsize do
    for j = 1, gridsize do
      drawtile(grid[i][j], i, j)
    end
  end

  love.graphics.setColor(yellow)
  love.graphics.rectangle('line', pixels(x), pixels(y), tilesize, tilesize)

  love.graphics.setColor(white)

  love.graphics.setFont(swapfont)
  printcentered('SWAP', pixels(gridsize + 1), pixels(gridsize - 2))
  love.graphics.setFont(whatfont)
  drawtile(swap, gridsize + 1, gridsize - 1)

end
