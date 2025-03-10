Shader "Stencil/Outline"
{
    Properties
    {
        _Color("Color", Color) = (1,0,0,1)
        _Thickness("Thickness", Range(0, 80)) = 4
    }
        SubShader
    {
 
        Tags { "Queue" = "Geometry" "IgnoreProjector" = "True" "RenderType" = "Transparent" }
        Blend SrcAlpha OneMinusSrcAlpha
        Cull Back
        ZTest always
        Pass
        {
            Stencil {
                Ref 1
                Comp always
                Pass replace
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
 
            #include "UnityCG.cginc"
 
            struct v2g
            {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
                float3 viewT : TANGENT;
                float3 normals : NORMAL;
            };
 
            struct g2f
            {
                float4  pos : SV_POSITION;
                float2  uv : TEXCOORD0;
                float3  viewT : TANGENT;
                float3  normals : NORMAL;
            };
 
            v2g vert(appdata_base v)
            {
                v2g OUT;
                OUT.pos = UnityObjectToClipPos(v.vertex);
                OUT.uv = v.texcoord;
                OUT.normals = v.normal;
                OUT.viewT = ObjSpaceViewDir(v.vertex);
 
                return OUT;
            }
 
            half4 frag(g2f IN) : COLOR
            {
                //this renders nothing, if you want the base mesh and color
                //fill this in with a standard fragment shader calculation
                return 0;
            }
            ENDCG
        }
        Pass
        {
            Stencil {
                Ref 0
                Comp equal
            }
            CGPROGRAM
            #include "UnityCG.cginc"
            #pragma target 4.0
            #pragma vertex vert
            #pragma geometry geom
            #pragma fragment frag
 
 
            half4 _Color;
            float _Thickness;
 
            struct v2g
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewT : TANGENT;
                float3 normals : NORMAL;
            };
 
            struct g2f
            {
                float4 pos : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 viewT : TANGENT;
                float3 normals : NORMAL;
            };
 
            v2g vert(appdata_base v)
            {
                v2g OUT;
                OUT.pos = UnityObjectToClipPos(v.vertex);
 
                OUT.uv = v.texcoord;
                OUT.normals = v.normal;
                OUT.viewT = ObjSpaceViewDir(v.vertex);
 
                return OUT;
            }
 
            void geom2(v2g start, v2g end, v2g third, inout TriangleStream<g2f> triStream)
            {
                float4 worldPos = mul(unity_ObjectToWorld, start.pos);
                float3 camVec = (worldPos.xyz - _WorldSpaceCameraPos.xyz);
                float camDist = sqrt(camVec.x*camVec.x + camVec.y*camVec.y + camVec.z*camVec.z);
 
                float3 fromCamDir = normalize(worldPos.xyz - _WorldSpaceCameraPos.xyz);
                float3 camForward = normalize(UNITY_MATRIX_V[2].xyz);
 
                float thisWidth = _Thickness / 100 * sqrt(camDist)/7;
                float4 parallel = end.pos - start.pos;
                normalize(parallel);
                parallel *= thisWidth;
                camForward *= -thisWidth;
 
                float4 perpendicular = float4(parallel.y, -parallel.x, 0, 0);
                //perpendicular = (normalize(perpendicular)) * thisWidth;
                perpendicular = (normalize(perpendicular) + float4(fromCamDir, 0)) * thisWidth;
                float4 v1 = start.pos - parallel/2;
                float4 v2 = end.pos + parallel/2;
                g2f OUT;
                OUT.pos = v1 - perpendicular;
                OUT.uv = start.uv;
                OUT.viewT = start.viewT;
                OUT.normals = start.normals;
                triStream.Append(OUT);
 
                OUT.pos = v1 + perpendicular;
                triStream.Append(OUT);
 
                OUT.pos = v2 - perpendicular;
                OUT.uv = end.uv;
                OUT.viewT = end.viewT;
                OUT.normals = end.normals;
                triStream.Append(OUT);
 
                OUT.pos = v2 + perpendicular;
                OUT.uv = end.uv;
                OUT.viewT = end.viewT;
                OUT.normals = end.normals;
                triStream.Append(OUT);
            }
 
            [maxvertexcount(12)]
            void geom(triangle v2g IN[3], inout TriangleStream<g2f> triStream)
            {
                geom2(IN[0],IN[1], IN[2],triStream);
                geom2(IN[1],IN[2], IN[0],triStream);
                geom2(IN[2],IN[0], IN[1],triStream);
            }
 
            half4 frag(g2f IN) : COLOR
            {
                _Color.a = 1;
                return _Color;
            }
 
            ENDCG
 
        }
    }
        FallBack "Diffuse"
}