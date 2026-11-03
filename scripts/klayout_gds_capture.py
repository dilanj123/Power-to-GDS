# KLayout batch macro: render an existing GDS with a fixed SKY130HD layer set.
# Run in the pinned OpenROAD image with GDS_INPUT, PNG_OUTPUT and LYP_PATH set.
import os
import pya

input_gds = os.environ['GDS_INPUT']
output_png = os.environ['PNG_OUTPUT']
layer_properties = os.environ['LYP_PATH']

layout = pya.Layout()
layout.read(input_gds)
view = pya.LayoutView()
view.show_layout(layout, False)
view.load_layer_props(layer_properties)

# Same display set and fit for A/B: metal 3-5 drawing.  The prBoundary layer
# is intentionally hidden because the platform styles it with a dense hatch
# that obscures the routed metal at portfolio-image scale.
visible = {(70, 20), (71, 20), (72, 20)}
for layer in view.each_layer():
    if layer.has_children():
        continue
    layer.visible = (layer.source_layer, layer.source_datatype) in visible
    layer.name = layer.name.split(' - ')[0]

view.set_config('grid-visible', 'false')
view.set_config('text-visible', 'false')
view.set_config('background-color', '#10151d')
view.max_hier()
view.zoom_fit()
view.save_image(output_png, 1440, 1080)
print('GDS_CAPTURE', input_gds, output_png, [cell.name for cell in layout.top_cells()])
