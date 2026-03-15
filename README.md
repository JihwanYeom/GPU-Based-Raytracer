<img width="1204" height="632" alt="Image" src="https://github.com/user-attachments/assets/265e62be-0941-46c4-beb9-0b9ddbf84460" />


# GPU-Based Raytracer

컴퓨터 그래픽스 과제로 **GLSL Fragment Shader 기반 Ray Tracing**을 구현한 프로젝트이다.  
각 Fragment에서 Ray를 생성하여 Sphere와의 교차를 계산하고 조명, 그림자, 반사 효과를 적용하여 최종 색상을 계산한다.

## Tech Stack

- OpenGL
- GLSL (Fragment Shader)
- Environment Mapping (Cube Map)

## 주요 기능

- Ray–Sphere 교차 판정
- Shadow Ray 기반 그림자 처리
- Phong Shading (Diffuse + Specular)
- Reflection Ray 기반 반사 효과
- Environment Mapping

## 구현 개요

Fragment Shader에서 카메라 위치로부터 Ray를 생성하여 Scene과의 교차 여부를 계산한다.

- Ray가 물체와 교차하면  
  → 교차 지점에서 **Phong Shading**을 적용한다.

- 광원 방향으로 **Shadow Ray**를 발사하여  
  → 다른 물체에 의해 가려질 경우 **그림자**를 생성한다.

- 반사 계수를 이용하여 **Reflection Ray**를 생성하고  
  → 일정 횟수까지 반사를 반복한다.

- Ray가 물체와 교차하지 않을 경우  
  → **Environment Map**에서 색상을 샘플링한다.

## 핵심 수식
Ray = P = O + tD
Sphere = |P - C|² = r²

위 두 식을 결합하여 이차방정식을 풀어 **Ray–Sphere 교차 여부를 판별**한다.

## 결과

GLSL Fragment Shader에서 다음 효과를 구현하였다.

- Reflection
- Shadow
- Environment Mapping

## Author

염지환  
세종대학교 소프트웨어학과
