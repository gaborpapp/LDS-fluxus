varying vec3 N;
varying vec3 P;

void main()
{
    vec4 eyeDir =  gl_ProjectionMatrix * vec4(0, 0, -1, 1);
    vec3 L = normalize(gl_LightSource[0].position.xyz - P); 
    vec3 E = normalize(-eyeDir.xyz);
    vec3 R = normalize(-reflect(L, N));
    
    float diff = max(dot( N, L ), 0.0);
    
    vec4 Ispec = vec4(1, 1, 1, 1);
    Ispec *= pow(max(dot( R, E ), 0.0), gl_FrontMaterial.shininess);
    Ispec = clamp(Ispec, 0.0, 1.0);

    gl_FragColor = gl_Color*diff + Ispec + gl_FrontMaterial.ambient;
}
