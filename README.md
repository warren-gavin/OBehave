# OBehave
A collection of drag and drop view controller behaviors

A behavior is a unit of code that does a single job that may be reused in multiple areas of a project or projects.

Using composition, view controllers are given ownership of a behavior in Interface Builder (or the storyboard).
Composition is favoured over inheriting functionality from a base view controller for the following reasons:

  1.  Behaviors can be re-used across multiple projects
  1.  A base view controller with lots of code that may be used by some
      but not all subclassed view controllers is poor design.
  1.  Using behaviors provides true separation of concerns.
  1.  View controllers are reduced in size

See http://www.objc.io/issue-13/behaviors.html for details.

Additionally, in this library a behavior can have a data source, a delegate and an effect
object, each of which can add individual and specific functionality to the behavior which 
will help customise a behavior as it's used per instance.

For instance, in a behavior that displays an action sheet, the text displayed in the sheet
can be customised by a data source, while the functionality of the behavior is unchanged
