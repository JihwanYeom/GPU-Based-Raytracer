#version 330

in vec3 N3; 
in vec3 L3; 
in vec3 V3; 
in vec3 wV;
in vec3 wP;
in vec3 wN;

out vec4 fColor;

struct Material {
	vec4  k_d;	// diffuse coefficient
	vec4  k_s;	// specular coefficient
	float n;	// specular exponent
};

struct Sphere {
	vec4     center;
	float    radius;
	Material mtl;
};

struct Ray {
	vec3 pos;
	vec3 dir;
};

struct HitInfo {
	float    t;
	vec4     position;
	vec3     normal;
	Material mtl;
};

uniform mat4 uModelMat; 
uniform mat4 uViewMat; 
uniform mat4 uProjMat; 
uniform vec4 uLPos; 
uniform vec4 uLIntensity;
uniform vec4 uAmb; 
uniform vec4 uDif; 
uniform vec4 uSpc; 
uniform float uShininess; 
uniform samplerCube uCube;
uniform vec4 uEPos;
uniform int uNumSphere;
uniform Sphere uSpheres[20];
uniform int uBounceLimit;
uniform int uDrawingMode;

bool IntersectRay( inout HitInfo hit, Ray ray );

// Shades the given point and returns the computed color.
vec4 Shade( Material mtl, vec4 position, vec3 normal, vec3 view )
{
	vec4 color = vec4(0,0,0,1);
	vec3 L = normalize((uLPos - position).xyz);
	vec3 R = 2*dot(normal, L)*normal - L;
	// TO-DO: Check for shadows
	Ray shadowRay;
	shadowRay.pos = position.xyz + normal*0.001;
	shadowRay.dir = L;
	HitInfo shadowHit;

	if(!IntersectRay( shadowHit, shadowRay )) {
		// TO-DO: If not shadowed, perform shading using the diffuse color only
		color += mtl.k_d * uLIntensity * dot(normal, L);	// change this line
		color += mtl.k_s * uLIntensity * pow(dot(R, view), mtl.n);
	}

	return color;
}

// Intersects the given ray with all spheres in the scene
// and updates the given HitInfo using the information of the sphere
// that first intersects with the ray.
// Returns true if an intersection is found.
bool IntersectRay( inout HitInfo hit, Ray ray )
{
	hit.t = 1e30;
	bool foundHit = false;
	for ( int i=0; i<uNumSphere; ++i ) {
		// TO-DO: Test for ray-sphere intersection
		// TO-DO: If intersection is found, update the given HitInfo
		Sphere s = uSpheres[i];
		vec3 k = ray.pos - s.center.xyz;
		float a = 1.0f;
		float b = dot(k, ray.dir);
		float c = dot(k, k) - pow(s.radius,2);

		float D = b*b - a*c;
		if(D >= 0) {
            float t = -b - sqrt(D);

            if (t > 0 && t < hit.t) {
                hit.t = t;
                hit.position.xyz = ray.pos + t * ray.dir;
                hit.normal = normalize(hit.position.xyz - s.center.xyz);
                hit.mtl = s.mtl;
                foundHit = true;
            }
		}
	}
	return foundHit;
}

// Given a ray, returns the shaded color where the ray intersects a sphere.
// If the ray does not hit a sphere, returns the environment color.
vec4 RayTracer( Ray ray )
{
	HitInfo hit;
	if ( IntersectRay( hit, ray ) ) {
		vec3 view = normalize( -ray.dir );
		vec4 clr = Shade( hit.mtl, hit.position, hit.normal, view );

		// Compute reflections
		vec4 k_s = hit.mtl.k_s;
		for ( int bounce=0; bounce<uBounceLimit; bounce++ ) {
			if ( hit.mtl.k_s.r + hit.mtl.k_s.g + hit.mtl.k_s.b <= 0.0 ) break;
			
			Ray r;	// this is the reflection ray
			HitInfo h;	// reflection hit info
						
			// TO-DO: Initialize the reflection ray
			r.pos = hit.position.xyz;
			r.dir = -(2*dot(hit.normal, ray.dir)*hit.normal - ray.dir);
			//r.dir = reflect(ray.dir, hit.normal);

			if ( IntersectRay( h, r ) ) {
				// TO-DO: Hit found, so shade the hit point
				// TO-DO: Update the loop variables for tracing the next reflection ray
				
				clr += k_s * Shade(h.mtl, h.position, h.normal, view);
				k_s *= h.mtl.k_s;
				ray = r;
				hit = h;
			} else {
				// The refleciton ray did not intersect with anything,
				// so we are using the environment color
				clr += k_s * texture(uCube, vec3(1,-1,1)*r.dir);
				break;	// no more reflections
			}
		}
		return clr;	// return the accumulated color, including the reflections
	} else {
		return texture(uCube, vec3(1,-1,1)*ray.dir);	// return the environment color
	}
}

void main()
{
	if(uDrawingMode == 0) 
	{
		vec3 N = normalize(N3); 
		vec3 L = normalize(L3); 
		vec3 V = normalize(V3); 
		vec3 H = normalize(V+L); 

		float NL = max(dot(N, L), 0); 
		float VR = pow(max(dot(H, N), 0), uShininess); 

		fColor = uAmb + uLIntensity*uDif*NL + uLIntensity*uSpc*VR; 
		fColor.w = 1; 

		vec3 viewDir = wP - wV;
		vec3 dir = reflect(viewDir, wN);

		fColor += uSpc*texture(uCube, vec3(1,-1,1)*dir);
	}
	else if(uDrawingMode == 1)
	{
		Ray r;
		r.pos = wV;
		r.dir = normalize(wP - wV);
		fColor = RayTracer (r);
	}
}
