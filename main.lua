function love.load()
  game_over = false

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

  flowamt = 0 -- in tiles (fractional)
  flowspeed = 0.2 -- in tiles / second

  whatfont = love.graphics.setNewFont(48)
  swapfont = love.graphics.newFont(32)

  BLOCKED = 0
  LEFT = 1
  RIGHT = 2
  DOWN = 3
  UP = 4

  local connector = function(a, b)
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
    if flow[x][y].filled > 0 then
      return
    end

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
  local size = margin + (i - 1) * tilesize
  -- FIXME hack
  if i > gridsize then
    size = size + margin
  end
  return size
end

function printcentered(text, xpos, ypos)
  local font = love.graphics.getFont()
  local width = font:getWidth(text)
  local height = font:getHeight()
  love.graphics.print(
    text,
    xpos + (tilesize - width) / 2,
    ypos + (tilesize - height) / 2
  )
end

function drawtile(tile, i, j, filled, from)
  local xpos = pixels(i)
  local ypos = pixels(j)

  if not filled then
    filled = 0
  end

  local smallr = tilesize / 4
  local bigr = 3 * tilesize / 4

  if tile.hidden then
    love.graphics.setColor(white)
    printcentered('?', xpos, ypos)
  elseif tile.kind == HORIZONTAL then
    love.graphics.setColor(grey)
    love.graphics.rectangle(
      'fill', xpos, ypos + (tilesize / 4), tilesize, tilesize / 2)

    love.graphics.setColor(aquamarine)
    local fillwidth = tilesize * filled
    if from == LEFT then
      love.graphics.rectangle(
        'fill', xpos, ypos + (tilesize / 4), fillwidth, tilesize / 2)
    elseif from == RIGHT then
      love.graphics.rectangle(
        'fill', xpos + (tilesize - fillwidth), ypos + (tilesize / 4), fillwidth, tilesize / 2)
    end

  elseif tile.kind == VERTICAL then
    love.graphics.setColor(grey)
    love.graphics.rectangle(
      'fill', xpos + (tilesize / 4), ypos, tilesize / 2, tilesize)

    love.graphics.setColor(aquamarine)
    local fillheight = tilesize * filled
    if from == UP then
      love.graphics.rectangle(
        'fill', xpos + (tilesize / 4), ypos, tilesize / 2, fillheight)
    elseif from == DOWN then
      love.graphics.rectangle(
        'fill', xpos + (tilesize / 4), ypos + (tilesize - fillheight), tilesize / 2, fillheight)
    end

  else
    local centerx, centery, angfrom, angto
    if tile.kind == LEFTUP then
      centerx = xpos
      centery = ypos
      if from == UP then
        angfrom = 0
        angto = math.pi / 2
      else
        angto = 0
        angfrom = math.pi / 2
      end
    elseif tile.kind == LEFTDOWN then
      centerx = xpos
      centery = ypos + tilesize
      if from == LEFT then
        angfrom = 3 * math.pi / 2
        angto = 2 * math.pi
      else
        angto = 3 * math.pi / 2
        angfrom = 2 * math.pi
      end
    elseif tile.kind == RIGHTUP then
      centerx = xpos + tilesize
      centery = ypos
      if from == RIGHT then
        angfrom = math.pi / 2
        angto = math.pi
      else
        angto = math.pi / 2
        angfrom = math.pi
      end
    elseif tile.kind == RIGHTDOWN then
      centerx = xpos + tilesize
      centery = ypos + tilesize
      if from == DOWN then
        angfrom = math.pi
        angto = 3 * math.pi / 2
      else
        angto = math.pi
        angfrom = 3 * math.pi / 2
      end
    end
    love.graphics.setColor(grey)
    love.graphics.arc('fill', centerx, centery, bigr, angfrom, angto)

    love.graphics.setColor(aquamarine)
    love.graphics.arc(
      'fill', centerx, centery, bigr,
      angfrom, angfrom + (angto - angfrom) * filled)

    love.graphics.setColor(black)
    love.graphics.arc('fill', centerx, centery, smallr, angfrom, angto)
  end

  love.graphics.setColor(white)
  love.graphics.rectangle('line',  xpos, ypos, tilesize, tilesize)
end

function love.update(dt)
  if game_over then
    return
  end

  flowamt = flowamt + flowspeed * dt

  flow = {}
  for i = 1, gridsize do
    flow[i] = {}
    for j = 1, gridsize do
      flow[i][j] = {filled = 0, from = BLOCKED}
    end
  end

  local posx = startx
  local posy = starty
  local amtleft = flowamt
  local from = UP

  while amtleft > 0 do
    flow[posx][posy] = {filled = math.min(amtleft, 1), from = from}
    amtleft = amtleft - flow[posx][posy].filled

    if amtleft > 0 then
      local dest = grid[posx][posy].kind(from)
      if dest == RIGHT then
        posx = posx + 1
        from = LEFT
      elseif dest == LEFT then
        posx = posx - 1
        from = RIGHT
      elseif dest == UP then
        posy = posy - 1
        from = DOWN
      elseif dest == DOWN then
        posy = posy + 1
        from = UP
      end

      if (posx < 1 or posx > gridsize or posy < 1 or posy > gridsize) or
         grid[posx][posy].hidden or
         grid[posx][posy].kind(from) == BLOCKED then
        game_over = true
        return
      end
    end
  end

end

function love.draw()
  love.graphics.setColor(black)
  love.graphics.clear()

  if game_over then
    love.graphics.setColor(white)
    love.graphics.print('GAME OVER', 200, 200)
    return
  end

  for i = 1, gridsize do
    for j = 1, gridsize do
      drawtile(grid[i][j], i, j, flow[i][j].filled, flow[i][j].from)
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
