#include "CorbaNameService.hpp"

using namespace RTT::Communication;

/**
 * @brief Constructor of the Corba Name Service.
 */
CorbaNameService::CorbaNameService()
{

}

/**
 * @brief Destructor of the Corba Name Service.
 */
CorbaNameService::~CorbaNameService()
{

}

/**
 * @brief Gets the URI for the current task context.
 * 
 * @return std::string
 */
std::string CorbaNameService::getURI(std::string Name)
{
  std::string URI = "";
  
  return URI;
}

/**
 * @brief Registers the taskcontext at the nameservice
 * 
 * @param taskcontext The task context
 * @return bool
 */
bool CorbaNameService::RegisterTaskContextServer(std::string Name, TaskContextServerCollection& tcsCollection)
{
  return true;
}
