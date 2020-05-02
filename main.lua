WINDOW_WIDTH=1280
WINDOW_HEIGHT=720

VIRTUAL_WIDTH=432
VIRTUAL_HEIGHT=243

PADDLE_SPEED=200

push=require 'push'


Class=require 'class'
require 'Paddle'
require 'Ball'

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.window.setTitle('Pong')
    math.randomseed(os.time())
        smallfont= love.graphics.newFont('font.ttf', 8)
        love.graphics.setFont(smallfont)
        score=love.graphics.newFont('font.ttf', 32)
        largeFont=love.graphics.newFont('font.ttf', 16)
        sounds = {
            ['paddle_hit']=love.audio.newSource('sounds/paddle_hit.wav','static'),
            ['score']=love.audio.newSource('sounds/score.wav','static'),
            ['wall_hit']=love.audio.newSource('sounds/wall_hit.wav','static')
        }
        push:setupScreen(VIRTUAL_WIDTH,VIRTUAL_HEIGHT,WINDOW_WIDTH,WINDOW_HEIGHT,{
            fullscreen=false,
            resizable=true,
            vsync=true
        })
        
    servingPlayer=1


    PLAYER1=Paddle(10,30,5,20)    
    PLAYER2=Paddle(VIRTUAL_WIDTH-10,VIRTUAL_HEIGHT - 50,5,20)
    
    SCORE1=0
    SCORE2=0

    ball=Ball(VIRTUAL_WIDTH/2-2,VIRTUAL_HEIGHT/2-2,4,4)
    gamestate='start'

   
end

function love.resize(w,h)
    push:resize(w,h)
end
   
function love.update(dt)
    if gamestate=='serve'   then
        ball.dy=math.random(-50,50)    
        if servingPlayer==1  then
        ball.dx=math.random(140,200)
        else
        ball.dx=-math.random(140,200)
        end
    elseif gamestate=='play' then
        if ball:collision(PLAYER1)  then
            ball.dx=-ball.dx*1.03
            ball.x=PLAYER1.x+5

            if ball.dy < 0  then
                ball.dy=-math.random(10,150)
            else
                ball.dy=math.random(10,150)
            end
            
            sounds['paddle_hit']:play()

        end

        if ball:collision(PLAYER2)  then
            ball.dx=-ball.dx*1.03
            ball.x=PLAYER2.x-4

            if ball.dy < 0  then
                ball.dy=-math.random(10,150)
            else
                ball.dy=math.random(10,150)
            end

            sounds['paddle_hit']:play()

        end

        if ball.y<=0    then
            ball.y=0
            ball.dy=-ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y>=VIRTUAL_HEIGHT-4     then
            ball.y=VIRTUAL_HEIGHT-4
            ball.dy=-ball.dy
            sounds['wall_hit']:play()
        end
    end

    if ball.x < 0 then
        servingPlayer=1
        SCORE2=SCORE2+1
        sounds['score']:play()
        ball:reset()
        gamestate='serve'

        if SCORE2==10 then
            wins=2
            gamestate='done'
        end
    end

    if ball.x > VIRTUAL_WIDTH then
        servingPlayer=2
        SCORE1=SCORE1+1
        sounds['score']:play()
        ball:reset()
        gamestate='serve'

        if SCORE1==10 then

            wins=1
            gamestate='done'
        end
    end
    
    if love.keyboard.isDown('w') then
        PLAYER1.dy=-PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        PLAYER1.dy=PADDLE_SPEED
    else
        PLAYER1.dy=0
    end

   PLAYER2.y=ball.y
   


    if(gamestate=='play') then
        ball:update(dt)
    end
    PLAYER1:update(dt)
    PLAYER2:update(dt)
end

function love.draw()
    push:apply('start')
    love.graphics.clear(40/255,45/255,52/255, 1)
    love.graphics.setFont(smallfont)

    displayscore()

    if gamestate=='start'  then
        love.graphics.setFont(smallfont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Play', 0,20,VIRTUAL_WIDTH,'center')
    elseif gamestate=='serve' then
        love.graphics.setFont(smallfont)
        love.graphics.printf('Player'..tostring(servingPlayer).."'s Serve",0,10,VIRTUAL_WIDTH,'center')
        love.graphics.printf('Press Enter to Serve!', 0,20,VIRTUAL_WIDTH,'center')
    elseif gamestate =='play' then
        --nothing to render in this state
    elseif gamestate =='done' then
        love.graphics.setFont(largeFont)
        love.graphics.printf('Player '..tostring(wins)..'wins!', 0,10,VIRTUAL_WIDTH,'center')
        love.graphics.setFont(smallfont)
        love.graphics.printf('Player '..tostring(servingPlayer).."'s serve",0,27,VIRTUAL_WIDTH,'center')
    end
    PLAYER1:render()
    PLAYER2:render()
    ball:render()

    displayFPS()
    push:apply('end')
end

function love.keypressed(key)
    if key=='escape'    then
        love.event.quit()
    elseif key=='enter' or key=='return'    then
        if gamestate=='start'   then
            gamestate='serve'
        elseif gamestate=='serve' then
            gamestate='play'
        elseif gamestate=='done' then
            gamestate='serve'

            ball:reset()

            SCORE1=0
            SCORE2=0

            if wins==1  then
                servingPlayer=2
            else
                servingPlayer=1
            end
        end
    end
end

function displayFPS()
    love.graphics.setFont(smallfont)
    love.graphics.setColor(0,1,0,1)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10 ,10)
end

function displayscore()
    love.graphics.setFont(score)
    love.graphics.print(tostring(SCORE1), VIRTUAL_WIDTH/2 - 50, VIRTUAL_HEIGHT/3)
    love.graphics.print(tostring(SCORE2),VIRTUAL_WIDTH/2 +30, VIRTUAL_HEIGHT/3)
end