--                              -*- Mode: Ada -*-
--  Filename        : sdl-video-palettes.ads
--  Description     : Palettes, colours and various conversions.
--  Author          : Luke A. Guest
--  Created On      : Tue Sep 24 20:17:57 2013
with Ada.Finalization;
with Ada.Iterator_Interfaces;
with Interfaces.C.Pointers;

package SDL.Video.Palettes is
   package C renames Interfaces.C;

   type Colour_Component is range 0 .. 255 with
     Size       => 8,
     Convention => C;

   type Colour is
      record
         Red   : Colour_Component;
         Green : Colour_Component;
         Blue  : Colour_Component;
         alpha : Colour_Component;
      end record with
        Convention => C,
        Size       => Colour_Component'Size * 4;

   for Colour use
      record
         Red   at 0 range  0 ..  7;
         Green at 0 range  8 .. 15;
         Blue  at 0 range 16 .. 23;
         Alpha at 0 range 24 .. 31;
      end record;

   Null_Colour : constant Colour := Colour'(others => Colour_Component'First);

   --  Cursor type for our iterator.
   type Cursor is private;

   No_Element : constant Cursor;

   function Element (Position : in Cursor) return Colour;

   function Has_Element (Position : Cursor) return Boolean;

   --  Create the iterator interface package.
   package Palette_Iterator_Interfaces is new
     Ada.Iterator_Interfaces (Cursor, Has_Element);

   type Palette is tagged private with
     Default_Iterator  => Iterate,
     Iterator_Element  => Colour,
     Constant_Indexing => Constant_Reference;

   type Palette_Access is access Palette;

   function Constant_Reference
     (Container : aliased Palette;
      Position  : Cursor) return Colour;

   function Iterate (Container : Palette)
      return Palette_Iterator_Interfaces.Forward_Iterator'Class;

   Empty_Palette : constant Palette;
private
   type Colour_Array is array (C.size_t range <>) of aliased Colour with
     Convention => C;

   package Colour_Array_Pointer is new Interfaces.C.Pointers
     (Index              => C.size_t,
      Element            => Colour,
      Element_Array      => Colour_Array,
      Default_Terminator => Null_Colour);

   type Internal_Palette is
      record
         Total     : C.int;
         Colours   : Colour_array_Pointer.Pointer;
         Version   : Interfaces.Unsigned_32;
         Ref_Count : C.int;
      end record with
        Convention => C;

   type Internal_Palette_Access is access Internal_Palette with
     Convention => C;

   type Palette is tagged
      record
         Data : Internal_Palette;
      end record;

   type Palette_Constant_Access is access constant Palette;

   type Cursor is
      record
         Container : Palette_Constant_Access;
         Index     : Natural;
         Current   : Colour_array_Pointer.Pointer;
      end record;

   No_Element : constant Cursor := Cursor'(Container => null,
                                           Index     => Natural'First,
                                           Current   => null);

   Empty_Palette : constant Palette := Palette'
     (Data =>
        Internal_Palette'
        (Total     => 0,
         Colours   => null,
         Version   => 0,
         Ref_Count => 0));
end SDL.Video.Palettes;
