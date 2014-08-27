path = require( "path" )

class Style

  constructor: ( options ) ->
    @selector = options.selector
    @pixelRatio = options.pixelRatio || 1
    @hdpi = options.hdpi || "(min--moz-device-pixel-ratio: #{ @pixelRatio }),\n
(-o-min-device-pixel-ratio: #{ @pixelRatio }/1),\n
(-webkit-min-device-pixel-ratio: #{ @pixelRatio }),\n
(min-device-pixel-ratio: #{ @pixelRatio })"
    
    @resolveImageSelector = options.resolveImageSelector if options.resolveImageSelector

  css: ( selector, attributes ) ->
    "#{ selector } {\n#{ @cssStyle( attributes ) };\n}\n"
  
  cssStyle: ( attributes ) ->
    attributes.join ";\n"
  
  cssComment: ( comment ) ->
    "/*\n#{ comment }\n*/"
  
  resolveImageSelector: ( name ) ->
    name
  
  generate: ( options ) ->
    { imagePath, relativeImagePath, images, pixelRatio, width, height } = options
    relativeImagePath = relativeImagePath.replace /(\\+)/g, "/"
    @pixelRatio = pixelRatio || 1

    styles = [
      @css @selector + '()', [
        "  background-image: url( '#{ relativeImagePath }' )"
        "  background-repeat: no-repeat"
        "  background-size: #{ width / pixelRatio }px #{ height / pixelRatio }px"
      ]
    ]

    # Only add background-position, width and height for pixelRatio === 1.
    if pixelRatio is 1
      for image in images
        positionX = ( -image.cssx / pixelRatio )
        if positionX != 0
          positionXP = Math.abs(positionX)
          positionX = positionX+'px'
        else
          positionXP = 0

        positionY = ( -image.cssy / pixelRatio )
        if positionY != 0
          positionYP = Math.abs(positionY)
          positionY = positionY+'px'
        else
          positionYP = 0

        image.selector = @resolveImageSelector( image.name, image.path )

        attr = [
          "  width: #{ image.cssw / pixelRatio }px"
          "  height: #{ image.cssh / pixelRatio }px"
          "  background-position: #{positionX} #{positionY}"
        ]

        attrPercent = [
          "  width: #{ image.cssw / pixelRatio }px"
          "  height: #{ image.cssh / pixelRatio }px"
          "  background-position: ((#{ image.cssw / pixelRatio }/2+#{positionXP})/(#{width}))*100+0% ((#{ image.cssh / pixelRatio }/2+#{positionYP})/(#{height}))*100+0%"
        ]

        image.style = @cssStyle attr

        styles.push @css( @selector + '-' + image.selector + '(@ratio:1) when (@ratio = 1)', attr )
        styles.push @css( @selector + '-' + image.selector + '(@ratio:1) when (@ratio = 2)', attrPercent )
    
    styles.push ""
    css = styles.join "\n"
    
    if pixelRatio > 1
      css = @wrapMediaQuery( "    background-image: url( '#{ relativeImagePath }' );\n    background-size: #{ width / pixelRatio }px #{ height / pixelRatio }px; \n" )
  
    return css
  
  comment: ( comment ) ->
    @cssComment comment
    
  wrapMediaQuery: ( css ) ->
    "@media #{ @hdpi } {\n
#{ css }
  }\n"
  
module.exports = Style
