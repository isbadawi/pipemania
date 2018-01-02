function love.load()
  black = {0, 0, 0, 255}
  white = {255, 255, 255, 255}
  yellow = {255, 255, 0, 255}
  grey = {105, 105, 105, 255}
  aquamarine = {127, 255, 212, 255}

  filled = 0

  font = love.graphics.newFont(48)
  love.graphics.setFont(font)
  fontheight = font:getHeight()
  fontwhatwidth = font:getWidth('?')

  HIDDEN = 0
  HORIZONTAL = 1
  VERTICAL = 2
  LEFTUP = 3
  LEFTDOWN = 4
  RIGHTUP = 5
  RIGHTDOWN = 6

  tilesize = 100 -- pixels
  gridsize = 6
  margin = 10 -- pixels

  x = 1
  y = 1

  love.window.setMode(
    tilesize * gridsize + margin * 2,
    tilesize * gridsize + margin * 2
  )

  math.randomseed(os.time())

  grid = {}
  for i = 1, gridsize do
    grid[i] = {}
    for j = 1, gridsize do
      grid[i][j] = math.random(HIDDEN, RIGHTDOWN)
    end
  end
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
  end
end

function pixels(i)
  return margin + (i - 1) * tilesize
end

function drawtile(kind, i, j)
  xpos = pixels(i)
  ypos = pixels(j)

  smallr = tilesize / 4
  bigr = 3 * tilesize / 4

  if kind == HIDDEN then
    love.graphics.setColor(white)
    love.graphics.print(
      '?',
      xpos + (tilesize - fontwhatwidth) / 2,
      ypos + (tilesize - fontheight) / 2
    )
  elseif kind == HORIZONTAL then
    love.graphics.setColor(grey)
    love.graphics.rectangle(
      'fill', xpos, ypos + (tilesize / 4), tilesize, tilesize / 2)
    love.graphics.setColor(aquamarine)
    love.graphics.rectangle(
      'fill', xpos, ypos + (tilesize / 4), tilesize * filled, tilesize / 2)
  elseif kind == VERTICAL then
    love.graphics.setColor(grey)
    love.graphics.rectangle(
      'fill', xpos + (tilesize / 4), ypos, tilesize / 2, tilesize)
    love.graphics.setColor(aquamarine)
    love.graphics.rectangle(
      'fill', xpos + (tilesize / 4), ypos, tilesize / 2, tilesize * filled)
  else
    if kind == LEFTUP then
      centerx = xpos
      centery = ypos
      angfrom = 0
      argto = math.pi / 2
    elseif kind == LEFTDOWN then
      centerx = xpos
      centery = ypos + tilesize
      angfrom = 3 * math.pi / 2
      argto = 2 * math.pi
    elseif kind == RIGHTUP then
      centerx = xpos + tilesize
      centery = ypos
      angfrom = math.pi / 2
      argto = math.pi
    elseif kind == RIGHTDOWN then
      centerx = xpos + tilesize
      centery = ypos + tilesize
      angfrom = math.pi
      argto = 3 * math.pi / 2
    end
    love.graphics.setColor(grey)
    love.graphics.arc('fill', centerx, centery, bigr, angfrom, argto)
    love.graphics.setColor(aquamarine)
    love.graphics.arc(
      'fill', centerx, centery, bigr,
      angfrom, angfrom + (argto - angfrom) * filled)
    love.graphics.setColor(black)
    love.graphics.arc('fill', centerx, centery, smallr, angfrom, argto)
  end

  love.graphics.setColor(white)
  love.graphics.rectangle('line',  xpos, ypos, tilesize, tilesize)
end

function love.update(dt)
  filled = filled + 0.005
  if filled >= 1 then
    filled = 0
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
end
