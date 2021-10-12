# mineheat

Update 20210723 JvH:
- added new r0 calculation in pipeheat.m
- this slightly changes all T calculations, so ran new set of benchmark testbanks results

Update 20210720 JvH:
- testbank added
- first parameter sensistivity study option added
- several routines now have a 'verbose' switch for more info
- geometries.m extended with more models and with output param idiagn

Update 20210630 JvH: 
- mineflow now calls a different routine to calculate resistance coefficient
    using the Darcy-Weisbach formulation as described in Brown, 2003:
         r=f*8/(pi^2*g)*L/d^5
    this makes quite a difference to the hydraulic head variation, but not much to
    flow or heat exchange.

Update 20210629 JvH:
- created a branch heat_inflow
- modified code to correctly model heat contribution from external inflow
- on main branch, created a testbank option:
  this allows creating results from all geometries and writing them to file
  then later on, after changes are made, the tests can be done again and compared to the original tests
- also added this to heat_inflow branch           
  code seems to create identical results for all presently available geometries
- merged heat_inflow branch into main
- cleaned up code
- added igeom=103 (geometry103.m): as igeom5 (geometry_grid), but now with
  in/outflow arranged through q, while keeping only one fixed-head node in top-right corner
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

Update 20210609-1 JvH:
- cleaned up code

