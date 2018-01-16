-- Preinstatiations of common types.
-- Due to a bug, don't name them Float_IO and Integer_IO.

With Text_IO;
package FIO is new Text_IO.Float_IO (Float);

With Text_IO;
package IIO is new Text_IO.Integer_IO (Integer);
