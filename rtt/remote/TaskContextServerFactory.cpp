#include "TaskContextServerFactory.hpp"
#include "CorbaTaskContextServer.hpp"

using namespace RTT::Communication;


boost::atomic<TaskContextServerFactory*> TaskContextServerFactory::m_Instance(0);

/**
 * @brief Default contructor for the task context server factory
 * 
 */
TaskContextServerFactory::TaskContextServerFactory() {}

/**
 * @brief Default destructor for the task context server factory.
 * 
 */
TaskContextServerFactory::~TaskContextServerFactory() {}

/**
 * @brief Creates a task context server object based upon the desired implementation option.
 * 
 * @param eTaskContextServerImpl The desired implementation option.
 * @return RTT::Communication::TaskContextServerType
 */
TaskContextServerType TaskContextServerFactory::createTaskContextServer(TaskContextServerImplementation eTaskContextServerImpl)
{
  TaskContextServerType pTaskContextServer;

  // Return a task context server object depending on the task context server implementation type
  switch (eTaskContextServerImpl)
  {
  case TCS_CORBA:
    pTaskContextServer.reset(new CorbaTaskContextServer());
    break;
  default:
    pTaskContextServer.reset();
  }

  return pTaskContextServer;
}