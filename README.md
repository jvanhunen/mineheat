# mineheat

Update 20210609-1 JvH:
- cleaned up code

Update 20210609-2 JvH: 
- implemented and tested prescribed external in/outflow in model:
  - This is the parameter q in Todini & Pilati, 1987, eqn. 1, 6, 8, and 
    (notably) 18.
  - In the TP87 paper, q can only be prescribed on nodes without a fixed 
    head, so this is the present restriction in code as well.
- tested this with new geometries: 
  - 101: as geometry 1, but removing inflow fixed-head 
         (so leaving only the outflow fixed-head)
         and instead prescribe q = -1.575e-4 on that first node
           (this value is chosen since it corresponds with the 
            developed flow in geometry 1; note that negative means inflow)
         -> results almost identical to those of geometry1
  - 102: as geometry 1 and 101, but with fixed-head node in middle
         and first and last point of domain both having fixed in/outflow:
         q(1) = -1.575e-4, q(nn) = 1.575e-4
         -> again, results identical to geom 1 and 101


           
