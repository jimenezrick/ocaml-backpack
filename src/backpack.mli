module Unix :
  sig
    external asctime : Unix.tm -> string = "caml_backpack_asctime"
    external fsync : Unix.file_descr -> unit = "caml_backpack_fsync"
    external fdatasync : Unix.file_descr -> unit = "caml_backpack_fdatasync"
  end
module StringMap :
  sig
    type key = String.t
    type 'a t = 'a Map.Make(String).t
    val empty : 'a t
    val is_empty : 'a t -> bool
    val mem : key -> 'a t -> bool
    val add : key -> 'a -> 'a t -> 'a t
    val singleton : key -> 'a -> 'a t
    val remove : key -> 'a t -> 'a t
    val merge :
      (key -> 'a option -> 'b option -> 'c option) -> 'a t -> 'b t -> 'c t
    val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val for_all : (key -> 'a -> bool) -> 'a t -> bool
    val exists : (key -> 'a -> bool) -> 'a t -> bool
    val filter : (key -> 'a -> bool) -> 'a t -> 'a t
    val partition : (key -> 'a -> bool) -> 'a t -> 'a t * 'a t
    val cardinal : 'a t -> int
    val bindings : 'a t -> (key * 'a) list
    val min_binding : 'a t -> key * 'a
    val max_binding : 'a t -> key * 'a
    val choose : 'a t -> key * 'a
    val split : key -> 'a t -> 'a t * 'a option * 'a t
    val find : key -> 'a t -> 'a
    val map : ('a -> 'b) -> 'a t -> 'b t
    val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t
  end
module IntMap :
  sig
    type key = int
    type +'a t
    val empty : 'a t
    val is_empty : 'a t -> bool
    val mem : key -> 'a t -> bool
    val add : key -> 'a -> 'a t -> 'a t
    val singleton : key -> 'a -> 'a t
    val remove : key -> 'a t -> 'a t
    val merge :
      (key -> 'a option -> 'b option -> 'c option) -> 'a t -> 'b t -> 'c t
    val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
    val iter : (key -> 'a -> unit) -> 'a t -> unit
    val fold : (key -> 'a -> 'b -> 'b) -> 'a t -> 'b -> 'b
    val for_all : (key -> 'a -> bool) -> 'a t -> bool
    val exists : (key -> 'a -> bool) -> 'a t -> bool
    val filter : (key -> 'a -> bool) -> 'a t -> 'a t
    val partition : (key -> 'a -> bool) -> 'a t -> 'a t * 'a t
    val cardinal : 'a t -> int
    val bindings : 'a t -> (key * 'a) list
    val min_binding : 'a t -> key * 'a
    val max_binding : 'a t -> key * 'a
    val choose : 'a t -> key * 'a
    val split : key -> 'a t -> 'a t * 'a option * 'a t
    val find : key -> 'a t -> 'a
    val map : ('a -> 'b) -> 'a t -> 'b t
    val mapi : (key -> 'a -> 'b) -> 'a t -> 'b t
  end
module OptionMonad :
  sig
    val ( >>= ) : 'a option -> ('a -> 'b option) -> 'b option
    val ( >> ) : 'a option -> 'b option -> 'b option
    val return : 'a -> 'a option
    val fail : string -> 'a
  end
module Op :
  sig
    val id : 'a -> 'a
    val ( |. ) : ('a -> 'b) -> ('c -> 'a) -> 'c -> 'b
    val ( $ ) : ('a -> 'b) -> 'a -> 'b
    val ( |< ) : 'a -> ('a -> 'b) -> 'b
  end
module Char :
  sig
    val is_blank : char -> bool
    val is_num : char -> bool
    val is_alpha : char -> bool
    val is_alphanum : char -> bool
  end
module Str :
  sig val explode : string -> char list val implode : char list -> string end
module LazyList :
  sig
    type 'a node = Nil | Cons of 'a * 'a t
    and 'a t = 'a node Lazy.t
    val force : 'a Lazy.t -> 'a
    val nil : 'a node Lazy.t
    val cons : 'a -> 'a t -> 'a node Lazy.t
    val hd : 'a node Lazy.t -> 'a
    val tl : 'a node Lazy.t -> 'a t
    val next : 'a node Lazy.t -> 'a * 'a t
    val is_empty : 'a node Lazy.t -> bool
    val map : ('a -> 'b) -> 'a node Lazy.t -> 'b t
    val filter : ('a -> bool) -> 'a node Lazy.t -> 'a node Lazy.t
    val take : int -> 'a node Lazy.t -> 'a t
    val drop : int -> 'a node Lazy.t -> 'a node Lazy.t
    val iter : ('a -> 'b) -> 'a node Lazy.t -> unit
    val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b node Lazy.t -> 'a
    val fold_right : ('a -> 'b -> 'b) -> 'b -> 'a node Lazy.t -> 'b
    val find : ('a -> bool) -> 'a node Lazy.t -> 'a
    val append : 'a node Lazy.t -> 'a node Lazy.t -> 'a t
    val concat : 'a node Lazy.t node Lazy.t -> 'a node Lazy.t
    val to_list : 'a node Lazy.t -> 'a list
    val from : (int -> 'a option) -> 'a node lazy_t
    val of_list : 'a list -> 'a t
    val of_string : string -> char node lazy_t
    val of_stream : 'a Stream.t -> 'a t
    val of_channel : in_channel -> char t
  end
