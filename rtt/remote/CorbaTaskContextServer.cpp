#include "CorbaTaskContextServer.hpp"

using namespace RTT::Communication;

/**
 * @brief Constructor of the Corba Task Context Server.
 */
CorbaTaskContextServer::CorbaTaskContextServer()
{
}

/**
 * @brief Destructor of the Corba Task Context Server.
 */
CorbaTaskContextServer::~CorbaTaskContextServer()
{
}

/**
 * @brief Registers the given taskcontext at the given name services.
 * 
 * @param pTaskContext Reference to the task context.
 * @param pNameServiceCollection Reference to the collection of name services, where the task context shall be registered.
 * @return bool
 */
bool CorbaTaskContextServer::Initialize(RTT::TaskContext* pTaskContext, NameServiceCollection* pNameServiceCollection)
{
  return true;
}

/**
 * @brief Starts the execution of task context.
 * 
 * @param StartThreaded Determines, whether the task context shall be started in the current thread or in its own thread.
 * @return bool
 */
bool CorbaTaskContextServer::Start(bool StartThreaded)
{
  return true;
}

/**
 * @brief Stops the execution of the task context.
 * 
 * @return bool
 */
bool CorbaTaskContextServer::Stop()
{
  return true;
}

/**
 * @brief Deletes a TaskContext server for a given task context.
 * 
 * @param pTaskContext Reference to the task context.
 * @return bool
 */
bool CorbaTaskContextServer::Delete(RTT::TaskContext* pTaskContext)
{
  return true;
}
/**
 * @brief Deletes all existing task context server objects.
 * 
 * @return bool
 */
bool CorbaTaskContextServer::DeleteAll()
{

}