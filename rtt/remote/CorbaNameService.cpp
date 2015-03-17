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
 * @brief Gets the canoncial name for the current task context.
 * 
 * @return std::string
 */
std::string CorbaNameService::getCanonicalName()
{
  std::string CanonicalName = "";
  
  return CanonicalName;
}

/**
 * @brief Gets the URI for the current task context.
 * 
 * @return std::string
 */
std::string CorbaNameService::getURI()
{
  std::string URI = "";
  
  return URI;
}
