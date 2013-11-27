if Meteor.isClient
  ctx = document.createElement('canvas').getContext '2d'
else
  # TODO: Is OK if size here is hard-coded? Is it too big? Is this even used on the server?
  ctx = new PDFJS.canvas(1000, 1000).getContext '2d'

PDFJS.pdfTextSegment = (textContent, textContentIndex, geom) ->
  fontHeight = geom.fontSize * Math.abs(geom.vScale)
  canvasWidth = geom.canvasWidth * Math.abs(geom.hScale)
  angle = geom.angle * (180 / Math.PI)

  segment =
    geom: geom
    text: textContent.bidiTexts[textContentIndex].str
    direction: textContent.bidiTexts[textContentIndex].dir
    textContentIndex: textContentIndex
    hasWidth: false

  segment.isWhitespace = !/\S/.test(segment.text)

  segment.style =
    fontSize: fontHeight
    fontFamily: geom.fontFamily
    left: geom.x + fontHeight * Math.sin(geom.angle)
    top: geom.y - fontHeight * Math.cos(geom.angle)

  unless segment.isWhitespace
    ctx.font = "#{ segment.style.fontSize }px #{ segment.style.fontFamily }";
    width = ctx.measureText(segment.text).width

    if width > 0
      segment.hasWidth = true
      segment.style.transform = "rotate(#{ angle }deg) scale(#{ canvasWidth / width }, 1)";
      segment.style.transformOrigin = '0% 0%';

  segment.boundingBox =
    width: canvasWidth
    height: fontHeight
    left: segment.style.left
    top: segment.style.top

  # When the angle is not 0, we rotate and compute the bounding box of the rotated segment
  if geom.angle isnt 0.0
    x = [
      segment.boundingBox.left
      segment.boundingBox.left + segment.boundingBox.width * Math.cos(geom.angle)
      segment.boundingBox.left - segment.boundingBox.height * Math.sin(geom.angle)
      segment.boundingBox.left + segment.boundingBox.width * Math.cos(geom.angle) - segment.boundingBox.height * Math.sin(geom.angle)
    ]
    y = [
      segment.boundingBox.top
      segment.boundingBox.top + segment.boundingBox.width * Math.sin(geom.angle)
      segment.boundingBox.top + segment.boundingBox.height * Math.cos(geom.angle)
      segment.boundingBox.top + segment.boundingBox.width * Math.sin(geom.angle) + segment.boundingBox.height * Math.cos(geom.angle)
    ]

    segment.boundingBox.left = _.min(x)
    segment.boundingBox.top = _.min(y)

    segment.boundingBox.width = _.max(x) - segment.boundingBox.left
    segment.boundingBox.height = _.max(y) - segment.boundingBox.top

  segment

PDFJS.pdfImageSegment = (geom) ->
  geom: geom
  boundingBox: _.pick geom, 'left', 'top', 'width', 'height'
  style: _.pick geom, 'left', 'top', 'width', 'height'