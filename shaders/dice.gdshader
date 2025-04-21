shader_type canvas_item;

uniform float blue = 0.0; // you can assign a default value to uniforms

void fragment(){
  vec4 input_color = texture(TEXTURE, UV); // Read from texture
  input_color.b = input_color.b - blue;
  COLOR = input_color;
}