% Geometry 3D Toolbox
% Version 0.1 04-Mar-2005 .
%
%   Creation, transformations, algorithms and visualization of geometrical
%   3D primitives, such as points, lines, planes, polyhedra, circles and
%   spheres.
%   
%   - Angles are defined as follow :
%   THETA is the colatitude, the angle with the Oz axis
%   PHI is the angle of the projection on horizontal plane with the Ox axis
%   PSI is the 'roll', i.e. the rotation around the (THETA, PHI) direction
%
%   Base format for primitives :
%   Point:  [x0 y0 z0]
%   Vector: [dx dy dz]
%   Line:   [x0 y0 z0 dx dy dz]
%   Edge:   [x1 y1 z1 x2 y2 z2]
%   Plane:  [x0 y0 z0 dx1 dy1 dz1 dx2 dy2 dz2]
%   Sphere: [x0 y0 z0 R]
%   Circle: [x0 y0 z0 R PHI THETA PSI] (origin+center+normal+'roll').
%   
%   Polygon: array of points, the last point is not necessarily the same as
%       the first one. Points must be coplanar.
%
%   Polyedron: {N, F}, with:
%       N = [x1 y1 z1; ... ;xn yn zn];
%       F is either a [Nf*3] or [Nf*4] array containing reference for
%          vertices of each face, or a [Nf*1] cell array, where each cell
%          is an array containing a variable number of node indices.
%
%   Box: [xmin xmax ymin ymax zmin zmax]. Used for clipping shapes.
%
% 3D Points and Vectors
%   isCoplanar               - Tests input points for coplanarity in 3-space.
%   transformPoint3d         - transform a point with a 3D affine transform
%   normalize3d              - normalize a 3D vector
%   distancePoints3d         - compute euclidean distance between 3D Points
%   isParallel3d             - check parallelism of two vectors
%   isPerpendicular3d        - check orthogonality of two vectors
%   vecnorm3d                - compute norm of vector or of set of 3D vectors
%   anglePoints3d            - compute angle between 2 3D points
%   sphericalAngle           - compute angle on the sphere
%   angleSort3d              - sort 3D coplanar points according to their angles in plane
%   randomAngle3d            - return a 3D angle uniformly distributed on unit sphere
%
% Coordinate transforms
%   sph2cart2                - convert spherical coordinate to cartesian coordinate
%   cart2sph2                - convert cartesian 2 spherical coordinate
%   cart2cyl                 - Convert cartesian to cylindrical coordinates
%   cyl2cart                 - Convert cylindrical to cartesian coordinates
%
% 3D Lines and Edges:
%   createLine3d             - create a line with various inputs.
%   distancePointLine3d      - compute euclidean distance between 3D point and line
%   linePosition3d           - return position of a 3D point on a 3D line
%
% Planes:
%   medianPlane              - create a plane in the middle of 2 points
%   createPlane              - create a plane in parametrized form
%   normalizePlane           - normalize parametric form of a plane
%   intersectPlanes          - return intersection between 2 planes in space
%   projPointOnPlane         - return the projection of a point on a plane
%   isBelowPlane             - test whether a point is below or above a plane
%   intersectLinePlane       - return intersection between a plane and a line
%   intersectEdgePlane       - return intersection between a plane and a edge
%   distancePointPlane       - compute euclidean distance betwen 3D point and plane
%   planeNormal              - compute the normal to a plane
%   planePosition            - compute position of a point on a plane
%   dihedralAngle            - compute dihedral angle between 2 planes
%
% 3D Polygons:
%   clipPolygon3dPlane       - clip a 3D polygon with Half-space
%   clipConvexPolygon3dPlane - clip a convex 3D polygon with Half-space
%   polygon3dNormalAngle     - compute normal angle at a vertex of the 3D polygon
%
% Polyhedra:
%   createCube               - create a 3D cube
%   createCubeOctahedron     - create a cube-octahedron
%   createIcosahedron        - create an Icosahedron.
%   createOctahedron         - create an octahedron
%   createRhombododecahedron - create a 3D rhombododecahedron
%   createTetrahedron        - create a tetrahedron  with 4 vertices and faces
%   createTetrakaidecahedron - create a tetrakaidecahedron
%   createSoccerBall         - return a soccerball as a polyhedra
%   minConvexHull            - return the unique minimal convex hull in 3D
%   steinerPolytope          - Create a steiner polytope from a set of vectors
%   faceCentroids            - compute centoids of faces of a polyhedron
%   faceNormal               - compute normal vector of a polyhedron face
%   polyhedronNormalAngle    - compute normal angle at a vertex of a 3D polyhedron
%   clipConvexPolyhedronPlane - clip a convex polyhedron by a plane
%
% Other shapes:
%   circle3dPosition         - return the angular position of a point on a 3D circle
%   circle3dOrigin           - return the first point of a 3D circle
%   createSphere             - create a sphere containing 4 points
%   intersectLineSphere      - return intersection between a line and a sphere
%   intersectPlaneSphere     - return intersection between a plane and a sphere
%   revolutionSurface        - create a surface of revolution from a planar curve
%   surfaceCurvature         - compute curvature on a surface in a given direction 
%
% Geometric transforms:
%   translation3d            - return 4x4 matrix of a 3D translation
%   rotationOx               - return 4x4 matrix of a rotation around x-axis
%   rotationOy               - return 4x4 matrix of a rotation around y-axis
%   rotationOz               - return 4x4 matrix of a rotation around z-axis
%   scale3d                  - return 4x4 matrix of a 3D scaling
%   composeTransforms3d      - concatenate several space transformations
%
% Drawing Functions :
%   drawCircle3d             - draw a 3D circle
%   drawCircleArc3d          - draw a 3D circle arc
%   drawCurve3d              - draw a 3D curve specified by a list of points
%   drawCylinder             - draw a cylinder
%   drawEdge3d               - draw the edge in the current Window
%   drawLine3d               - draw the line in the current Window
%   drawPlane3d              - draw a plane clipped in the current window
%   drawPoint3d              - draw 3D point on the current axis.
%   drawPolyhedra            - draw polyhedra defined by vertices and faces
%   drawSphere               - draw a sphere as a mesh
%   drawSphericalTriangle    - draw a triangle on a sphere
%   drawSurfPatch            - draw surface patch, with 2 parametrized surfaces
%   drawGrid3d               - draw a grid in 3 dimensions
%   fillPolygon3d            - fill a 3D polygon specified by a list of points
%   drawAxis                 - draw a coordinate system and an origin
%
%
%   Credits:
%   * function isCoplanar was originally written by Brett Shoelson.
%   * Songbai Ji enhanced file intersectPlaneLine (6/23/2006).
%
%   ------
%   Author: David Legland
%   e-mail: david.legland@jouy.inra.fr
%   Created: 2005-11-07
%   Copyright 2005 INRA - CEPIA Nantes - MIAJ (Jouy-en-Josas).
%   Licensed under the terms of the LGPL, see the file "license.txt'

