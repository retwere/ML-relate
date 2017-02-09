(:
Copyright 2016 MarkLogic Corporation 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
:)

import module namespace geojson = "http://marklogic.com/geospatial/geojson" at "/MarkLogic/geospatial/geojson.xqy";
declare option xdmp:coordinate-system "raw/double";

let $input := xdmp:get-request-body()

let $regionA := fn:string($input/regionA)
let $regionB := fn:string($input/regionB)
let $tol := $input/tolerance
let $cs := $input/cs
let $bdy := $input/boundary

(:let $i := geo:region-intersects($regionA,$regionB,("coordinate-system=wgs84/double" ,fn:concat("tolerance=",$tol) ,$bdy,"units=meters")) :)
let $opts := (fn:concat("coordinate-system=",$cs) ,fn:concat("tolerance=",$tol),"units=meters")
let $de9im := geo:region-de9im($regionA,$regionB,$opts)

let $crosses := geo:region-relate($regionA,"crosses",$regionB,$opts)
let $contains := geo:region-relate($regionA,"contains",$regionB,$opts)
let $covers := geo:region-relate($regionA,"covers",$regionB,$opts)
let $covered-by := geo:region-relate($regionA,"covered-by",$regionB,$opts)
let $disjoint := geo:region-relate($regionA,"disjoint",$regionB,$opts)
let $equals := geo:region-relate($regionA,"equals",$regionB,$opts)
let $intersects := geo:region-relate($regionA,"intersects",$regionB,$opts)
let $overlaps := geo:region-relate($regionA,"overlaps",$regionB,$opts)
let $touches := geo:region-relate($regionA,"touches",$regionB,$opts)
let $within := geo:region-relate($regionA,"within",$regionB,$opts)

let $outA := try {
  let $geomA := geojson:to-geojson(cts:region($regionA))
  return object-node {
    "str":geo:to-wkt($regionA),
    "feature": object-node { "type":"Feature", "geometry":$geomA }
  }
} catch($e) {
  object-node {
    "str":$regionA
  }
}

let $outB := try {
  let $geomB := geojson:to-geojson(cts:region($regionB))
  return object-node {
    "str":geo:to-wkt($regionB),
    "feature": object-node { "type":"Feature", "geometry":$geomB }
  }
} catch($e) {
  object-node {
    "str":$regionB
  }
}


return object-node {
  "de9im": $de9im,
  "crosses": $crosses,
  "contains": $contains,
  "covers": $covers,
  "coveredBy": $covered-by,
  "disjoint": $disjoint,
  "equals": $equals,
  "intersects": $intersects,
  "overlaps": $overlaps,
  "touches": $touches,
  "within": $within,
  "regionA" : $outA,
  "regionB" : $outB
}
