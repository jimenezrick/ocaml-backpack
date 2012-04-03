include List

let cons h t = h :: t

let rec remove x = function
    | []                -> []
    | h :: t when h = x -> t
    | h :: t            -> h :: remove x t
