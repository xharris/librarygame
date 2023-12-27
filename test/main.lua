function love.load()
    love.window.close()

    require('test.isometric')
    require('test.pathfind')

    love.event.quit()
end