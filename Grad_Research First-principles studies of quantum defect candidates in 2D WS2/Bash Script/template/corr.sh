echo "slab {
  fromZ = 14.153 ;
  toZ = 20.058 ;
  epsilon = 15.29;
}

charge {
  posZ = 17.106 ;
  Q = +1. ;
}

isolated {
  fromZ = 10 ;
  toZ = 25 ;
}" > system.sx

ECUT="33.07"
VREF="vRef.sxb"
VDEF="vDef.sxb"
ISHIFT="0.0"

param="--vasp --ecut $ECUT --vref $VREF --vdef $VDEF --shift $ISHIFT"
/hpctmp/e1127489/template/sxdefectalign2d $param > NOTALIGNED.txt

dV=$(head -1 vline-eV.dat | awk '{print $4}')

param="$param -C $dV"
/hpctmp/e1127489/template/sxdefectalign2d $param > ALIGNED.txt

