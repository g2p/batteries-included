(*
 * ExtList - additional and modified functions for lists.
 * Copyright (C) 2003 Brian Hurt
 * Copyright (C) 2003 Nicolas Cannasse
 * Copyright (C) 2008 Red Hat Inc.
 * Copyright (C) 2008 David Teller
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version,
 * with the special exception on linking described in file LICENSE.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *)

(** Additional and modified functions for lists.

    The OCaml standard library provides a module for list functions.
    This ExtList module can be used to override the List module or
    as a standalone module. It provides new functions and modify
    the behavior of some other ones (in particular all functions
    are now {b tail-recursive}).

    The following functions have the same behavior as the [List]
    module ones but are tail-recursive: [map], [append], [concat],
    [flatten], [fold_right], [remove_assoc], [remove_assq],
    [split]. That means they will not
    cause a [Stack_overflow] when used on very long list.

    The implementation might be a little more slow in bytecode,
    but compiling in native code will not affect performances. 
*)

module List :
    sig

      (** List operations.  

	  @documents List *)


      (**{6 Base operations}*)
	val length : 'a list -> int
	  (** Return the length (number of elements) of the given list. *)

	val hd : 'a list -> 'a
	(** Returns the first element of the list or raise [Empty_list] if the
	 list is empty. *)

	val tl : 'a list -> 'a list
	(** Returns the list without its first elements or raise [Empty_list] if
	 the list is empty. *)

	val is_empty : 'a list -> bool
	  (** [is_empty e] returns true if [e] does not contains any element. *)

	val cons : 'a -> 'a list -> 'a list
	  (** [cons h t] returns the list starting with [h] and continuing as [t] *)

	val first : 'a list -> 'a
	  (** Returns the first element of the list, or raise [Empty_list] if
	      the list is empty (similar to [hd]). *)

	val last : 'a list -> 'a
	  (** Returns the last element of the list, or raise [Empty_list] if
	      the list is empty. This function takes linear time. *)

	val at : 'a list -> int -> 'a
	  (** [at l n] returns the n-th element of the list [l] or raise
	      [Invalid_index] is the index is outside of [l] bounds. *)

	val rev : 'a list -> 'a list
	  (** List reversal. *)

	val append : 'a list -> 'a list -> 'a list
	  (** Catenate two lists.  Same function as the infix operator [@].
	      Tail-recursive (length of the first argument).*)

	val rev_append : 'a list -> 'a list -> 'a list
	  (** [List.rev_append l1 l2] reverses [l1] and concatenates it to [l2].
	      This is equivalent to {!List.rev}[ l1 @ l2], but [rev_append] is
	      more efficient. *)

	val concat : 'a list list -> 'a list
	  (** Concatenate a list of lists.  The elements of the argument are all
	      concatenated together (in the same order) to give the result.
	      Tail-recursive
	      (length of the argument + length of the longest sub-list). *)

	val flatten : 'a list list -> 'a list
	  (** Same as [concat]. *)

	(**{6 Constructors}*)
	  
	val make : int -> 'a -> 'a list
	  (** Similar to [String.make], [make n x] returns a
	      list containing [n] elements [x]. *)

	val init : int -> (int -> 'a) -> 'a list
	(** Similar to [Array.init], [init n f] returns the list containing
	 the results of (f 0),(f 1).... (f (n-1)).
	 Raise [Invalid_arg "ExtList.init"] if n < 0.*)


	(**{6 Iterators}*)
	val iter : ('a -> unit) -> 'a list -> unit
	  (** [List.iter f [a1; ...; an]] applies function [f] in turn to
	      [a1; ...; an]. It is equivalent to
	      [begin f a1; f a2; ...; f an; () end]. *)

	val iteri : (int -> 'a -> 'b) -> 'a list -> unit
	(** [iteri f l] will call [(f 0 a0);(f 1 a1) ... (f n an)] where
	 [a0..an] are the elements of the list [l]. *)

	val map : ('a -> 'b) -> 'a list -> 'b list
	  (** [map f [a1; ...; an]] applies function [f] to [a1, ..., an],
	      and builds the list [[f a1; ...; f an]]
	      with the results returned by [f].  Tail-recursive. *)

	val mapi : (int -> 'a -> 'b) -> 'a list -> 'b list
	(** [mapi f l] will build the list containing
	 [(f 0 a0);(f 1 a1) ... (f n an)] where [a0..an] are the elements of
	 the list [l]. *)


	val rev_map : ('a -> 'b) -> 'a list -> 'b list
	  (** [List.rev_map f l] gives the same result as
	      {!List.rev}[ (]{!List.map}[ f l)], but is
	      more efficient. *)

	val fold_left : ('a -> 'b -> 'a) -> 'a -> 'b list -> 'a
	  (** [List.fold_left f a [b1; ...; bn]] is
	      [f (... (f (f a b1) b2) ...) bn]. *)

	val fold_right : ('a -> 'b -> 'b) -> 'a list -> 'b -> 'b
	  (** [List.fold_right f [a1; ...; an] b] is
	      [f a1 (f a2 (... (f an b) ...))].  Tail-recursive. *)



	(** {6 Iterators on two lists} *)
	val iter2 : ('a -> 'b -> unit) -> 'a list -> 'b list -> unit
	  (** [List.iter2 f [a1; ...; an] [b1; ...; bn]] calls in turn
	      [f a1 b1; ...; f an bn].
	      Raise [Different_list_size] if the two lists have
	      different lengths. *)

	val map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
	  (** [List.map2 f [a1; ...; an] [b1; ...; bn]] is
	      [[f a1 b1; ...; f an bn]].
	      Raise [Different_list_size] if the two lists have
	      different lengths.  Tail-recursive. *)

	val rev_map2 : ('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
	  (** [List.rev_map2 f l1 l2] gives the same result as
	      {!List.rev}[ (]{!List.map2}[ f l1 l2)], but is tail-recursive and
	      more efficient. *)

	val fold_left2 : ('a -> 'b -> 'c -> 'a) -> 'a -> 'b list -> 'c list -> 'a
	  (** [List.fold_left2 f a [b1; ...; bn] [c1; ...; cn]] is
	      [f (... (f (f a b1 c1) b2 c2) ...) bn cn].
	      Raise [Different_list_size] if the two lists have
	      different lengths. *)

	val fold_right2 : ('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> 'c -> 'c
	  (** [List.fold_right2 f [a1; ...; an] [b1; ...; bn] c] is
	      [f a1 b1 (f a2 b2 (... (f an bn c) ...))].
	      Raise [Different_list_size] if the two lists have
	      different lengths.  Tail-recursive. *)

	  (**{6 List scanning}*)
	val for_all : ('a -> bool) -> 'a list -> bool
	  (** [for_all p [a1; ...; an]] checks if all elements of the list
	      satisfy the predicate [p]. That is, it returns
	      [(p a1) && (p a2) && ... && (p an)]. *)

	val exists : ('a -> bool) -> 'a list -> bool
	  (** [exists p [a1; ...; an]] checks if at least one element of
	      the list satisfies the predicate [p]. That is, it returns
	      [(p a1) || (p a2) || ... || (p an)]. *)

	val for_all2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
	  (** Same as {!List.for_all}, but for a two-argument predicate.
	      Raise [Invalid_argument] if the two lists have
	      different lengths. *)

	val exists2 : ('a -> 'b -> bool) -> 'a list -> 'b list -> bool
	  (** Same as {!List.exists}, but for a two-argument predicate.
	      Raise [Invalid_argument] if the two lists have
	      different lengths. *)

	val mem : 'a -> 'a list -> bool
	  (** [mem a l] is true if and only if [a] is equal
	      to an element of [l]. *)

	val memq : 'a -> 'a list -> bool
	  (** Same as {!List.mem}, but uses physical equality instead of structural
	      equality to compare list elements. *)

	(**{6 List searching}*)


	val find : ('a -> bool) -> 'a list -> 'a
	  (** [find p l] returns the first element of [l] such as [p x]
	      returns [true] or raises [Not_found] if such an element
	      has not been found.*)

	val find_exn : ('a -> bool) -> exn -> 'a list -> 'a
	(** [find_exn p e l] returns the first element of [l] such as [p x]
	 returns [true] or raises [e] if such an element has not been found. *)

	val findi : (int -> 'a -> bool) -> 'a list -> (int * 'a)
	(** [findi p e l] returns the first element [ai] of [l] along with its
	 index [i] such that [p i ai] is true, or raises [Not_found] if no
	 such element has been found. *)

	val find_map : ('a -> 'b option) -> 'a list -> 'b
        (** [find_map pred list] finds the first element of [list] for which
            [pred element] returns [Some r].  It returns [r] immediately
            once found or raises [Not_found] if no element matches the
            predicate.  See also {!filter_map}. *)


	val rfind : ('a -> bool) -> 'a list -> 'a
	(** [rfind p l] returns the last element [x] of [l] such as [p x] returns
	 [true] or raises [Not_found] if such element as not been found. *)

	val filter : ('a -> bool) -> 'a list -> 'a list
	  (** [filter p l] returns all the elements of the list [l]
	      that satisfy the predicate [p].  The order of the elements
	      in the input list is preserved.  *)

	val filter_map : ('a -> 'b option) -> 'a list -> 'b list
	(** [filter_map f l] call [(f a0) (f a1).... (f an)] where [a0..an] are
	 the elements of [l]. It returns the list of elements [bi] such as
	 [f ai = Some bi] (when [f] returns [None], the corresponding element of
	 [l] is discarded). *)

	val find_all : ('a -> bool) -> 'a list -> 'a list
	  (** [find_all] is another name for {!List.filter}. *)

	val partition : ('a -> bool) -> 'a list -> 'a list * 'a list
	  (** [partition p l] returns a pair of lists [(l1, l2)], where
	      [l1] is the list of all the elements of [l] that
	      satisfy the predicate [p], and [l2] is the list of all the
	      elements of [l] that do not satisfy [p].
	      The order of the elements in the input list is preserved. *)

	val index_of : 'a -> 'a list -> int option
        (** [index_of e l] returns the index of the first occurrence of [e]
	    in [l], or [None] if there is no occurrence of [e] in [l] *)

	val index_ofq : 'a -> 'a list -> int option
        (** [index_ofq e l] behaves as [index_of e l] except it uses
	    physical equality*)

	val rindex_of : 'a -> 'a list -> int option
        (** [rindex_of e l] returns the index of the last occurrence of [e]
	    in [l], or [None] if there is no occurrence of [e] in [l] *)

	val rindex_ofq : 'a -> 'a list -> int option
        (** [rindex_ofq e l] behaves as [rindex_of e l] except it uses
	    physical equality*)

	val unique : ?cmp:('a -> 'a -> bool) -> 'a list -> 'a list
	(** [unique cmp l] returns the list [l] without any duplicate element.
	 Default comparator ( = ) is used if no comparison function specified. *)

	  (**{6 Association lists}*)
	val assoc : 'a -> ('a * 'b) list -> 'b
	  (** [assoc a l] returns the value associated with key [a] in the list of
	      pairs [l]. That is,
	      [assoc a [ ...; (a,b); ...] = b]
	      if [(a,b)] is the leftmost binding of [a] in list [l].
	      Raise [Not_found] if there is no value associated with [a] in the
	      list [l]. *)

	val assoc_inv : 'b -> ('a * 'b) list -> 'a
	  (** [assoc_inv b l] returns the key associated with value [b] in the list of
	      pairs [l]. That is,
	      [assoc b [ ...; (a,b); ...] = a]
	      if [(a,b)] is the leftmost binding of [a] in list [l].
	      Raise [Not_found] if there is no key associated with [b] in the
	      list [l]. *)

	val assq : 'a -> ('a * 'b) list -> 'b
	  (** As {!assoc} but with physical equality *)

	val mem_assoc : 'a -> ('a * 'b) list -> bool
	  (** As {!assoc} but simply returns [true] if a binding exists, [false]
	      otherwise. *)

	val mem_assq : 'a -> ('a * 'b) list -> bool
	  (** As {!mem_assoc} but with physical equality.*)

	val remove_assoc : 'a -> ('a * 'b) list -> ('a * 'b) list
	  (** [remove_assoc a l] returns the list of
	      pairs [l] without the first pair with key [a], if any.
	      Tail-recursive. *)

	val remove_assq : 'a -> ('a * 'b) list -> ('a * 'b) list
	  (** Same as {!List.remove_assoc}, but uses physical equality instead
	      of structural equality to compare keys.  Tail-recursive. *)


	(** {6 List transformations}*)
	val split_at : int -> 'a list -> 'a list * 'a list
	(** [split_at n l] returns two lists [l1] and [l2], [l1] containing the
	 first [n] elements of [l] and [l2] the others. Raise [Invalid_index] if
	 [n] is outside of [l] size bounds. *)

	val split_nth : int -> 'a list -> 'a list * 'a list
	(** Obsolete. As [split_at]. *)

	val remove : 'a list -> 'a -> 'a list
	(** [remove l x] returns the list [l] without the first element [x] found
	 or returns  [l] if no element is equal to [x]. Elements are compared
	 using ( = ). *)

	val remove_if : ('a -> bool) -> 'a list -> 'a list
	(** [remove_if cmp l] is similar to [remove], but with [cmp] used
	 instead of ( = ). *)

	val remove_all : 'a list -> 'a -> 'a list
	(** [remove_all l x] is similar to [remove] but removes all elements that
	 are equal to [x] and not only the first one. *)

	val take : int -> 'a list -> 'a list
	(** [take n l] returns up to the [n] first elements from list [l], if
	 available. *)

	val drop : int -> 'a list -> 'a list
	  (** [drop n l] returns [l] without the first [n] elements, or the empty
	      list if [l] have less than [n] elements. *)

	val take_while : ('a -> bool) -> 'a list -> 'a list
	  (** [takewhile f xs] returns the first elements of list [xs]
	      which satisfy the predicate [f]. *)
	  
	val takewhile :  ('a -> bool) -> 'a list -> 'a list
	  (** obsolete, as {!take_while} *)
	  
	val drop_while : ('a -> bool) -> 'a list -> 'a list
	  (** [dropwhile f xs] returns the list [xs] with the first
	      elements satisfying the predicate [f] dropped. *)

	val dropwhile : ('a -> bool) -> 'a list -> 'a list
	  (** obsolete, as {!drop_while} *)

	val interleave : ?first:'a -> ?last:'a -> 'a -> 'a list -> 'a list
	  (** [interleave ~first ~last sep [a1;a2;a3;...;an]] returns
	      [first; a1; sep; a2; sep; a3; sep; ...; sep; an] *)

	(** {6 Enum functions} 
	    
	    Abstraction layer.*)

	val enum : 'a list -> 'a Enum.t
	(** Returns an enumeration of the elements of a list. This enumeration may
	    be used to visit elements of the list in forward order (i.e. from the
	    first element to the last one)*)

	val of_enum : 'a Enum.t -> 'a list
	(** Build a list from an enumeration. In the result, elements appear in the
	    same order as they did in the source enumeration. *)

	val backwards : 'a list -> 'a Enum.t
	(** Returns an enumeration of the elements of a list. This enumeration may
	    be used to visit elements of the list in backwards order (i.e. from the
	    last element to the first one)*)

	val of_backwards : 'a Enum.t -> 'a list
	(** Build a list from an enumeration. The first element of the enumeration
	    becomes the last element of the list, the second element of the enumeration
	    becomes the second-to-last element of the list... *)



	  (** {6 List of pairs}*)
	  
	val split : ('a * 'b) list -> 'a list * 'b list
	  (** Transform a list of pairs into a pair of lists:
	      [split [(a1,b1); ...; (an,bn)]] is [([a1; ...; an], [b1; ...; bn])].
	      Tail-recursive.
	  *)

	val combine : 'a list -> 'b list -> ('a * 'b) list
	  (** Transform a pair of lists into a list of pairs:
	      [combine [a1; ...; an] [b1; ...; bn]] is
	      [[(a1,b1); ...; (an,bn)]].
	      Raise [Different_list_size] if the two lists
	      have different lengths.  Tail-recursive. *)

	(** {6 Utilities}*)
	val make_compare : ('a -> 'a -> int) -> 'a list -> 'a list -> int
	  (** [make_compare c] generates the lexicographical order on lists
	      induced by [c]*)

	val sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
	  (** Sort the list using optional comparator (by default [compare]). *)

	val stable_sort : ('a -> 'a -> int) -> 'a list -> 'a list
	  (** Same as {!List.sort}, but the sorting algorithm is guaranteed to
	      be stable (i.e. elements that compare equal are kept in their
	      original order) .

	      The current implementation uses Merge Sort. It runs in constant
	      heap space and logarithmic stack space.
	  *)
	  
	val fast_sort : ('a -> 'a -> int) -> 'a list -> 'a list
	  (** Same as {!List.sort} or {!List.stable_sort}, whichever is faster
	      on typical input. *)
	  
	val merge : ('a -> 'a -> int) -> 'a list -> 'a list -> 'a list
	  (** Merge two lists:
	      Assuming that [l1] and [l2] are sorted according to the
	      comparison function [cmp], [merge cmp l1 l2] will return a
	      sorted list containting all the elements of [l1] and [l2].
	      If several elements compare equal, the elements of [l1] will be
	      before the elements of [l2].
	      Not tail-recursive (sum of the lengths of the arguments).
	  *)

	(** {6 Exceptions} *)

	exception Empty_list
	(** [Empty_list] is raised when an operation applied on an empty list
		is invalid : [hd] for example. *)

	exception Invalid_index of int
	(** [Invalid_index] is raised when an indexed access on a list is
		out of list bounds. *)

	exception Different_list_size of string
	(** [Different_list_size] is raised when applying functions such as
		[iter2] on two lists having different size. *)

	(** {6 Obsolete functions} *)
	val nth : 'a list -> int -> 'a
	(** Obsolete. As [at]. *)


	module ExceptionLess : sig
	  (** Exceptionless counterparts for error-raising operations*)

	  val rfind : ('a -> bool) -> 'a list -> 'a option
	    (** [rfind p l] returns [Some x] where [x] is the last element of [l] such 
		that [p x] returns [true] or [None] if such element as not been found. *)

	  val findi : (int -> 'a -> bool) -> 'a list -> (int * 'a) option
	    (** [findi p e l] returns [Some (i, ai)] where [ai] and [i] are respectively the 
		first element of [l] and its index, such that [p i ai] is true, 
		or [None] if no	such element has been found. *)

	  val split_at : int -> 'a list -> [`Ok of ('a list * 'a list) | `Invalid_index of int]
	    (** Whenever [n] is inside of [l] size bounds, [split_at n l] returns 
		[Ok(l1,l2)], where [l1] contains the first [n] elements of [l] and [l2] 
		contains the others. Otherwise, returns [`Invalid_index n] *)

	  val at : 'a list -> int -> [`Ok of 'a | `Invalid_index of int]
	    (** If [n] is inside the bounds of [l], [at l n] returns [Ok x], where
		[x] is the n-th element of the list [l]. Otherwise, returns [Error
		(`Invalid_index(n))].*)


	  val assoc : 'a -> ('a * 'b) list -> 'b option
	    (** [assoc a l] returns [Some b] where [b] is the value associated with key [a] 
		in the list of pairs [l]. That is, [assoc a [ ...; (a,b); ...] = Some b]
		if [(a,b)] is the leftmost binding of [a] in list [l].
		Return [None] if there is no value associated with [a] in the
		list [l]. *)

	  val assoc_inv : 'b -> ('a * 'b) list -> 'a option
	    (** [assoc_inv b l] returns [Some a] where [a] is the key associated with value [a] 
		in the list of pairs [l]. That is, [assoc b [ ...; (a,b); ...] = Some a]
		if [(a,b)] is the leftmost binding of [a] in list [l].
		Return [None] if there is no key associated with [b] in the
		list [l]. *)


	  val assq : 'a -> ('a * 'b) list -> 'b option
	    (** As {!assoc} but with physical equality. *)
	end
    end

module ListLabels :
    sig

      (** List operations.  *)


      (**{6 Base operations}*)
	val length : 'a list -> int
	  (** Return the length (number of elements) of the given list. *)

	val hd : 'a list -> 'a
	(** Returns the first element of the list or raise [Empty_list] if the
	 list is empty. *)

	val tl : 'a list -> 'a list
	(** Returns the list without its first elements or raise [Empty_list] if
	 the list is empty. *)

	val is_empty : 'a list -> bool
	  (** [is_empty e] returns true if [e] does not contains any element. *)

	val cons : 'a -> 'a list -> 'a list
	  (** [cons h t] returns the list starting with [h] and continuing as [t] *)

	val first : 'a list -> 'a
	  (** Returns the first element of the list, or raise [Empty_list] if
	      the list is empty (similar to [hd]). *)

	val last : 'a list -> 'a
	  (** Returns the last element of the list, or raise [Empty_list] if
	      the list is empty. This function takes linear time. *)

	val at : 'a list -> int -> 'a
	  (** [at l n] returns the n-th element of the list [l] or raise
	      [Invalid_index] is the index is outside of [l] bounds. *)

	val rev : 'a list -> 'a list
	  (** List reversal. *)

	val append : 'a list -> 'a list -> 'a list
	  (** Catenate two lists.  Same function as the infix operator [@].
	      Tail-recursive (length of the first argument).*)

	val rev_append : 'a list -> 'a list -> 'a list
	  (** [List.rev_append l1 l2] reverses [l1] and concatenates it to [l2].
	      This is equivalent to {!List.rev}[ l1 @ l2], but [rev_append] is
	      more efficient. *)

	val concat : 'a list list -> 'a list
	  (** Concatenate a list of lists.  The elements of the argument are all
	      concatenated together (in the same order) to give the result.
	      Tail-recursive
	      (length of the argument + length of the longest sub-list). *)

	val flatten : 'a list list -> 'a list
	  (** Same as [concat]. *)

	(**{6 Constructors}*)
	  
	val make : int -> 'a -> 'a list
	  (** Similar to [String.make], [make n x] returns a
	      list containing [n] elements [x]. *)

	val init : int -> f:(int -> 'a) -> 'a list
	(** Similar to [Array.init], [init n ~f:f] returns the list containing
	 the results of (f 0),(f 1).... (f (n-1)).
	 Raise [Invalid_arg "ExtList.init"] if n < 0.*)


	(**{6 Iterators}*)
	val iter : f:('a -> unit) -> 'a list -> unit
	  (** [List.iter ~f:f [a1; ...; an]] applies function [f] in turn to
	      [a1; ...; an]. It is equivalent to
	      [begin f a1; f a2; ...; f an; () end]. *)

	val iteri : f:(int -> 'a -> 'b) -> 'a list -> unit
	(** [iteri ~f:f l] will call [(f 0 a0);(f 1 a1) ... (f n an)] where
	 [a0..an] are the elements of the list [l]. *)

	val map : f:('a -> 'b) -> 'a list -> 'b list
	  (** [map ~f:f [a1; ...; an]] applies function [f] to [a1, ..., an],
	      and builds the list [[f a1; ...; f an]]
	      with the results returned by [f].  Tail-recursive. *)

	val mapi : f:(int -> 'a -> 'b) -> 'a list -> 'b list
	(** [mapi ~f:f l] will build the list containing
	 [(f 0 a0);(f 1 a1) ... (f n an)] where [a0..an] are the elements of
	 the list [l]. *)


	val rev_map : f:('a -> 'b) -> 'a list -> 'b list
	  (** [List.rev_map ~f:f l] gives the same result as
	      {!List.rev}[ (]{!List.map}[ f l)], but is
	      more efficient. *)

	val fold_left : f:('a -> 'b -> 'a) -> init:'a -> 'b list -> 'a
	  (** [List.fold_left ~f:f ~init:a [b1; ...; bn]] is
	      [f (... (f (f a b1) b2) ...) bn]. *)

	val fold_right : f:('a -> 'b -> 'b) -> 'a list -> init:'b -> 'b
	  (** [List.fold_right ~f:f [a1; ...; an] ~init:b] is
	      [f a1 (f a2 (... (f an b) ...))].  Tail-recursive. *)



	(** {6 Iterators on two lists} *)
	val iter2 : f:('a -> 'b -> unit) -> 'a list -> 'b list -> unit
	  (** [List.iter2 ~f:f [a1; ...; an] [b1; ...; bn]] calls in turn
	      [f a1 b1; ...; f an bn].
	      Raise [Different_list_size] if the two lists have
	      different lengths. *)

	val map2 : f:('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
	  (** [List.map2 ~f:f [a1; ...; an] [b1; ...; bn]] is
	      [[f a1 b1; ...; f an bn]].
	      Raise [Different_list_size] if the two lists have
	      different lengths.  Tail-recursive. *)

	val rev_map2 : f:('a -> 'b -> 'c) -> 'a list -> 'b list -> 'c list
	  (** [List.rev_map2 ~f:f l1 l2] gives the same result as
	      {!List.rev}[ (]{!List.map2}[ f l1 l2)], but is tail-recursive and
	      more efficient. *)

	val fold_left2 : f:('a -> 'b -> 'c -> 'a) -> init:'a -> 'b list -> 'c list -> 'a
	  (** [List.fold_left2 f:f ~init:a [b1; ...; bn] [c1; ...; cn]] is
	      [f (... (f (f a b1 c1) b2 c2) ...) bn cn].
	      Raise [Different_list_size] if the two lists have
	      different lengths. *)

	val fold_right2 : f:('a -> 'b -> 'c -> 'c) -> 'a list -> 'b list -> init:'c -> 'c
	  (** [List.fold_right2 ~f:f [a1; ...; an] [b1; ...; bn] ~init:c] is
	      [f a1 b1 (f a2 b2 (... (f an bn c) ...))].
	      Raise [Different_list_size] if the two lists have
	      different lengths.  Tail-recursive. *)

	  (**{6 List scanning}*)
	val for_all : f:('a -> bool) -> 'a list -> bool
	  (** [for_all ~f:p [a1; ...; an]] checks if all elements of the list
	      satisfy the predicate [p]. That is, it returns
	      [(p a1) && (p a2) && ... && (p an)]. *)

	val exists : f:('a -> bool) -> 'a list -> bool
	  (** [exists ~f:p [a1; ...; an]] checks if at least one element of
	      the list satisfies the predicate [p]. That is, it returns
	      [(p a1) || (p a2) || ... || (p an)]. *)

	val for_all2 : f:('a -> 'b -> bool) -> 'a list -> 'b list -> bool
	  (** Same as {!List.for_all}, but for a two-argument predicate.
	      Raise [Invalid_argument] if the two lists have
	      different lengths. *)

	val exists2 : f:('a -> 'b -> bool) -> 'a list -> 'b list -> bool
	  (** Same as {!List.exists}, but for a two-argument predicate.
	      Raise [Invalid_argument] if the two lists have
	      different lengths. *)

	val mem : 'a -> 'a list -> bool
	  (** [mem a l] is true if and only if [a] is equal
	      to an element of [l]. *)

	val memq : 'a -> 'a list -> bool
	  (** Same as {!List.mem}, but uses physical equality instead of structural
	      equality to compare list elements. *)

	(**{6 List searching}*)


	val find : f:('a -> bool) -> 'a list -> 'a
	  (** [find p l] returns the first element of [l] such as [p x]
	      returns [true] or raises [Not_found] if such an element
	      has not been found.*)

	val find_exn : f:('a -> bool) -> exn -> 'a list -> 'a
	(** [find_exn ~f:p e l] returns the first element of [l] such as [p x]
	 returns [true] or raises [e] if such an element has not been found. *)

	val findi : f:(int -> 'a -> bool) -> 'a list -> (int * 'a)
	(** [findi ~f:p e l] returns the first element [ai] of [l] along with its
	 index [i] such that [p i ai] is true, or raises [Not_found] if no
	 such element has been found. *)

	val rfind : f:('a -> bool) -> 'a list -> 'a
	(** [rfind ~f:p l] returns the last element [x] of [l] such as [p x] returns
	 [true] or raises [Not_found] if such element as not been found. *)

	val filter : f:('a -> bool) -> 'a list -> 'a list
	  (** [filter p l] returns all the elements of the list [l]
	      that satisfy the predicate [p].  The order of the elements
	      in the input list is preserved.  *)

	val filter_map : f:('a -> 'b option) -> 'a list -> 'b list
	(** [filter_map ~f:f l] call [(f a0) (f a1).... (f an)] where [a0..an] are
	 the elements of [l]. It returns the list of elements [bi] such as
	 [f ai = Some bi] (when [f] returns [None], the corresponding element of
	 [l] is discarded). *)

	val find_all : f:('a -> bool) -> 'a list -> 'a list
	  (** [find_all] is another name for {!List.filter}. *)

	val partition : f:('a -> bool) -> 'a list -> 'a list * 'a list
	  (** [partition ~f:p l] returns a pair of lists [(l1, l2)], where
	      [l1] is the list of all the elements of [l] that
	      satisfy the predicate [p], and [l2] is the list of all the
	      elements of [l] that do not satisfy [p].
	      The order of the elements in the input list is preserved. *)

	val index_of : 'a -> 'a list -> int option
        (** [index_of e l] returns the index of the first occurrence of [e]
	    in [l], or [None] if there is no occurrence of [e] in [l] *)

	val index_ofq : 'a -> 'a list -> int option
        (** [index_ofq e l] behaves as [index_of e l] except it uses
	    physical equality*)

	val rindex_of : 'a -> 'a list -> int option
        (** [rindex_of e l] returns the index of the last occurrence of [e]
	    in [l], or [None] if there is no occurrence of [e] in [l] *)

	val rindex_ofq : 'a -> 'a list -> int option
        (** [rindex_ofq e l] behaves as [rindex_of e l] except it uses
	    physical equality*)

	val unique : ?cmp:('a -> 'a -> bool) -> 'a list -> 'a list
	(** [unique cmp l] returns the list [l] without any duplicate element.
	 Default comparator ( = ) is used if no comparison function specified. *)

	  (**{6 Association lists}*)
	val assoc : 'a -> ('a * 'b) list -> 'b
	  (** [assoc a l] returns the value associated with key [a] in the list of
	      pairs [l]. That is,
	      [assoc a [ ...; (a,b); ...] = b]
	      if [(a,b)] is the leftmost binding of [a] in list [l].
	      Raise [Not_found] if there is no value associated with [a] in the
	      list [l]. *)

	val assoc_inv : 'b -> ('a * 'b) list -> 'a
	  (** [assoc_inv b l] returns the key associated with value [b] in the list of
	      pairs [l]. That is,
	      [assoc b [ ...; (a,b); ...] = a]
	      if [(a,b)] is the leftmost binding of [a] in list [l].
	      Raise [Not_found] if there is no key associated with [b] in the
	      list [l]. *)

	val assq : 'a -> ('a * 'b) list -> 'b
	  (** As {!assoc} but with physical equality *)

	val mem_assoc : 'a -> ('a * 'b) list -> bool
	  (** As {!assoc} but simply returns [true] if a binding exists, [false]
	      otherwise. *)

	val mem_assq : 'a -> ('a * 'b) list -> bool
	  (** As {!mem_assoc} but with physical equality.*)

	val remove_assoc : 'a -> ('a * 'b) list -> ('a * 'b) list
	  (** [remove_assoc a l] returns the list of
	      pairs [l] without the first pair with key [a], if any.
	      Tail-recursive. *)

	val remove_assq : 'a -> ('a * 'b) list -> ('a * 'b) list
	  (** Same as {!List.remove_assoc}, but uses physical equality instead
	      of structural equality to compare keys.  Tail-recursive. *)


	(** {6 List transformations}*)
	val split_at : int -> 'a list -> 'a list * 'a list
	(** [split_at n l] returns two lists [l1] and [l2], [l1] containing the
	 first [n] elements of [l] and [l2] the others. Raise [Invalid_index] if
	 [n] is outside of [l] size bounds. *)

	val split_nth : int -> 'a list -> 'a list * 'a list
	(** Obsolete. As [split_at]. *)

	val remove : 'a list -> 'a -> 'a list
	(** [remove l x] returns the list [l] without the first element [x] found
	 or returns  [l] if no element is equal to [x]. Elements are compared
	 using ( = ). *)

	val remove_if : f:('a -> bool) -> 'a list -> 'a list
	(** [remove_if ~f:cmp l] is similar to [remove], but with [cmp] used
	 instead of ( = ). *)

	val remove_all : 'a list -> 'a -> 'a list
	(** [remove_all l x] is similar to [remove] but removes all elements that
	 are equal to [x] and not only the first one. *)

	val take : int -> 'a list -> 'a list
	(** [take n l] returns up to the [n] first elements from list [l], if
	 available. *)

	val drop : int -> 'a list -> 'a list
	(** [drop n l] returns [l] without the first [n] elements, or the empty
	 list if [l] have less than [n] elements. *)

	val take_while : f:('a -> bool) -> 'a list -> 'a list
	  (** [take_while ~f:f xs] returns the first elements of list [xs]
	      which satisfy the predicate [f]. *)

	val drop_while : f:('a -> bool) -> 'a list -> 'a list
	  (** [drop_while f xs] returns the list [xs] with the first
	      elements satisfying the predicate [f] dropped. *)

	val interleave : ?first:'a -> ?last:'a -> 'a -> 'a list -> 'a list
	  (** [interleave ~first ~last sep [a1;a2;a3;...;an]] returns
	      [first; a1; sep; a2; sep; a3; sep; ...; sep; an] *)

	(** {6 Enum functions} 
	    
	    Abstraction layer.*)

	val enum : 'a list -> 'a Enum.t
	(** Returns an enumeration of the elements of a list. This enumeration may
	    be used to visit elements of the list in forward order (i.e. from the
	    first element to the last one)*)

	val of_enum : 'a Enum.t -> 'a list
	(** Build a list from an enumeration. In the result, elements appear in the
	    same order as they did in the source enumeration. *)

	val backwards : 'a list -> 'a Enum.t
	(** Returns an enumeration of the elements of a list. This enumeration may
	    be used to visit elements of the list in backwards order (i.e. from the
	    last element to the first one)*)

	val of_backwards : 'a Enum.t -> 'a list
	(** Build a list from an enumeration. The first element of the enumeration
	    becomes the last element of the list, the second element of the enumeration
	    becomes the second-to-last element of the list... *)



	  (** {6 List of pairs}*)
	  
	val split : ('a * 'b) list -> 'a list * 'b list
	  (** Transform a list of pairs into a pair of lists:
	      [split [(a1,b1); ...; (an,bn)]] is [([a1; ...; an], [b1; ...; bn])].
	      Tail-recursive.
	  *)

	val combine : 'a list -> 'b list -> ('a * 'b) list
	  (** Transform a pair of lists into a list of pairs:
	      [combine [a1; ...; an] [b1; ...; bn]] is
	      [[(a1,b1); ...; (an,bn)]].
	      Raise [Different_list_size] if the two lists
	      have different lengths.  Tail-recursive. *)

	(** {6 Utilities}*)
	val make_compare : ('a -> 'a -> int) -> 'a list -> 'a list -> int
	  (** [make_compare c] generates the lexicographical order on lists
	      induced by [c]*)

	val sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
	  (** Sort the list using optional comparator (by default [compare]). *)

	val stable_sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
	  (** Same as {!List.sort}, but the sorting algorithm is guaranteed to
	      be stable (i.e. elements that compare equal are kept in their
	      original order) .

	      The current implementation uses Merge Sort. It runs in constant
	      heap space and logarithmic stack space. *)
	  
	val fast_sort : ?cmp:('a -> 'a -> int) -> 'a list -> 'a list
	  (** Same as {!List.sort} or {!List.stable_sort}, whichever is faster
	      on typical input. *)
	  
	val merge : cmp:('a -> 'a -> int) -> 'a list -> 'a list -> 'a list
	  (** Merge two lists:
	      Assuming that [l1] and [l2] are sorted according to the
	      comparison function [cmp], [merge ~cmp:cmp l1 l2] will return a
	      sorted list containting all the elements of [l1] and [l2].
	      If several elements compare equal, the elements of [l1] will be
	      before the elements of [l2].
	      Not tail-recursive (sum of the lengths of the arguments).
	  *)


	(** {6 Exceptions} *)

	exception Empty_list
	(** [Empty_list] is raised when an operation applied on an empty list
		is invalid : [hd] for example. *)

	exception Invalid_index of int
	(** [Invalid_index] is raised when an indexed access on a list is
		out of list bounds. *)

	exception Different_list_size of string
	(** [Different_list_size] is raised when applying functions such as
		[iter2] on two lists having different size. *)

	(** {6 Obsolete functions} *)

	val nth : 'a list -> int -> 'a
	(** Obsolete. As [at]. *)


	module ExceptionLess : sig
	  (** Exceptionless counterparts for error-raising operations*)

	  val rfind : f:('a -> bool) -> 'a list -> 'a option
	    (** [rfind ~f:p l] returns [Some x] where [x] is the last element of [l] such 
		that [p x] returns [true] or [None] if such element as not been found. *)

	  val findi : f:(int -> 'a -> bool) -> 'a list -> (int * 'a) option
	    (** [findi ~f:p e l] returns [Some (i, ai)] where [ai] and [i] are respectively the 
		first element of [l] and its index, such that [p i ai] is true, 
		or [None] if no	such element has been found. *)

	  val split_at : int -> 'a list -> [`Ok of ('a list * 'a list) | `Invalid_index of int]
	    (** Whenever [n] is inside of [l] size bounds, [split_at n l] returns 
		[Ok(l1,l2)], where [l1] contains the first [n] elements of [l] and [l2] 
		contains the others. Otherwise, returns [`Invalid_index n] *)

	  val at : 'a list -> int -> [`Ok of 'a | `Invalid_index of int]
	    (** If [n] is inside the bounds of [l], [at l n] returns [Ok x], where
		[x] is the n-th element of the list [l]. Otherwise, returns [Error
		(`Invalid_index(n))].*)


	  val assoc : 'a -> ('a * 'b) list -> 'b option
	    (** [assoc a l] returns [Some b] where [b] is the value associated with key [a] 
		in the list of pairs [l]. That is, [assoc a [ ...; (a,b); ...] = Some b]
		if [(a,b)] is the leftmost binding of [a] in list [l].
		Return [None] if there is no value associated with [a] in the
		list [l]. *)

	  val assoc_inv : 'b -> ('a * 'b) list -> 'a option
	    (** [assoc_inv b l] returns [Some a] where [a] is the key associated with value [a] 
		in the list of pairs [l]. That is, [assoc b [ ...; (a,b); ...] = Some a]
		if [(a,b)] is the leftmost binding of [a] in list [l].
		Return [None] if there is no key associated with [b] in the
		list [l]. *)


	  val assq : 'a -> ('a * 'b) list -> 'b option
	    (** As {!assoc} but with physical equality *)	    
	end
    end

val ( @ ) : 'a list -> 'a list -> 'a list
(** the new implementation for ( @ ) operator, see [List.append]. *)
