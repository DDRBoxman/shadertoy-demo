// Vertex shader

struct VertexOutput {
    @builtin(position) fragCoord: vec4<f32>,
};

@vertex
fn vs_main(
    @builtin(vertex_index) in_vertex_index: u32,
) -> VertexOutput {

    var out: VertexOutput;
    let x = f32(i32((in_vertex_index << 1u) & 2u));
    let y = f32(i32(in_vertex_index & 2u));
    let uv = vec2<f32>(x, y);
    let pos = 2.0 * uv - vec2<f32>(1.0, 1.0);
    out.fragCoord = vec4<f32>(pos.x, pos.y, 0.0, 1.0);
    return out;
}

struct FragmentUniform {
    resolution: vec2<f32>,
    frame: f32,
    time: f32,
};
@group(0) @binding(0)
var<uniform> fragUniform: FragmentUniform;

fn palette( t: f32 ) -> vec3<f32> {
    let a = vec3<f32>(0.5, 0.5, 0.5);
    let b = vec3<f32>(0.5, 0.5, 0.5);
    let c = vec3<f32>(1.0, 1.0, 1.0);
    let d = vec3<f32>(0.263,0.416,0.557);

    return a + b*cos( 6.28318*(c*t+d) );
}

@fragment
fn fs_main(in: VertexOutput) -> @location(0) vec4<f32> {

    var uv = (in.fragCoord.xy * 2.0 - fragUniform.resolution.xy) / fragUniform.resolution.y;
    let uv0 = vec2<f32>(uv);
    var finalColor = vec3<f32>(0.0, 0.0, 0.0);
    
    for (var i = 0; i < 4; i++) {
        uv = fract(uv * 1.5) - 0.5;

        var d = length(uv) * exp(-length(uv0));

        let col = palette(length(uv0) + f32(i) * .4 + fragUniform.time*.4);

        d = sin(d*8. + fragUniform.time)/8.;
        d = abs(d);

        d = pow(0.01 / d, 1.2);

        finalColor += col * d;
    }
        
    return vec4<f32>(finalColor, 1.0);
}