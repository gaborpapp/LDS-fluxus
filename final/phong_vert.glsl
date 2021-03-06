varying vec3 N;
varying vec3 P;

void main()
{
	N = gl_NormalMatrix * gl_Normal;
	P = vec3(gl_ModelViewMatrix * gl_Vertex);

	gl_TexCoord[ 0 ] = gl_MultiTexCoord0;
	gl_FrontColor = gl_Color;
	gl_Position = ftransform();
}

