taskmgr
=======

iOS Task App Client

Note there are some issues with the build. 
-The Rest API does not return valid JSON on POST or PUT requests. 
-The API also does not return a task's "id" or "url", so the client must fetch all tasks to receive the full task object.
-Given more time there would have been significantly more documentation and some refactoring.
