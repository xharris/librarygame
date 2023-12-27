function love.load()
    love.window.close()

    require('test.gameengine') -- naming is test.engine caused require() loop...
    require('test.isometric')
    require('test.pathfind')

    love.event.quit()
end