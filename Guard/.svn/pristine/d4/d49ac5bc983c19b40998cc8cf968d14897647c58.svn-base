#include <map>
#include "+Msg/App.h"
#include "+Msg/Exec.h"
#include "+Msg/Proto.h"
#include "+math/Rotation.h"
#include "+earth/WGS84.h"
#include "JSONRead.h"

// protocol
#include "nav/nav.pb.cc"

// configuration
static JSONRead cfg("guard.json");

// An application that fuses sensor measurements to estimate the states of all vehicles present.
class ARDEstimator : virtual public Msg::App, virtual public Msg::Time, virtual public Msg::Log
{
private:
  std::map< std::string, nav::FusedState* > est;
  double timeDeltaS;
  
public:
  ARDEstimator(void) : 
    Msg::App("ARDEstimator", cfg.get<double>("fastTick"), cfg.get<double>("fastTick")), 
    Msg::Time(this, cfg.get<std::string>("timeSourceID"), cfg.get<double>("timeWarp")),
    Msg::Log(this)
  {
    this->timeDeltaS = cfg.get<double>("fastTick");
  }
    
  ~ARDEstimator(void)
  {
    std::map< std::string, nav::FusedState* >::iterator itr;
    for(itr = this->est.begin(); itr!=this->est.end(); ++itr)
    {
      delete itr->second;
      this->est.erase(itr);
    }
  }
  
  void topics(std::vector< std::string >& sub)
  {
    sub.clear();
    sub.push_back(Msg::Proto::topic("nav.RPY", ""));
    sub.push_back(Msg::Proto::topic("nav.LatLon", ""));
    sub.push_back(Msg::Proto::topic("nav.Alt", ""));
    sub.push_back(Msg::Proto::topic("nav.BodyRPYDelta", ""));
    sub.push_back(Msg::Proto::topic("nav.BodyFRDDelta", ""));
    sub.push_back(Msg::Proto::topic("nav.BodyFRDRateDelta", ""));
    sub.push_back(Msg::Proto::topic("nav.RelRPY", ""));
    sub.push_back(Msg::Proto::topic("nav.RelFRD", ""));
    return;
  }
  
  // Receive and process measurements.
  void process(const std::string& inbox)
  {
    nav::FusedState* own = NULL;
    std::string type;
    std::string id;
    std::string data;

    // require time to be set
    if(!this->isTimeSet())
    {
      return;
    }
    
    // process regular ticks
    if(inbox.empty())
    {
      this->onTick();
      return;
    }
    
    // process incoming message
    Msg::Proto::unpack(inbox, type, id, data);
       
    if(!type.compare("nav.RPY"))
    {
      nav::RPY pb;
      pb.ParseFromString(data);
      own = this->getEst(id);
      if(this->isValid(own->times(), pb.times()))
      {
        own->set_times(pb.times());
        own->set_rollr(pb.rollr());
        own->set_pitchr(pb.pitchr());
        own->set_yawr(pb.yawr());
      }
    }
    else if(!type.compare("nav.LatLon"))
    {
      nav::LatLon pb;
      pb.ParseFromString(data);
      own = this->getEst(id);
      if(this->isValid(own->times(), pb.times()))
      {
        own->set_times(pb.times());
        own->set_latr(pb.latr());
        own->set_lonr(pb.lonr());
      }
    }
    else if(!type.compare("nav.Alt"))
    {
      nav::Alt pb;
      pb.ParseFromString(data);
      own = this->getEst(id);
      if(this->isValid(own->times(), pb.times()))
      {
        own->set_times(pb.times());
        own->set_altm(pb.altm());
      }
    }
    else if(!type.compare("nav.BodyRPYDelta"))
    {
      nav::BodyRPYDelta pb;
      pb.ParseFromString(data);
      own = this->getEst(id);
      if(this->isValid(own->times(), pb.times()))
      {
        own->set_times(pb.times());
        //own->set_timedeltas(pb.timedeltas()); // assumed
        own->set_rolldeltar(pb.rolldeltar());
        own->set_pitchdeltar(pb.pitchdeltar());
        own->set_yawdeltar(pb.yawdeltar());
      }
    }
    else if(!type.compare("nav.BodyFRDDelta"))
    {
      nav::BodyFRDDelta pb;
      pb.ParseFromString(data);
      own = this->getEst(id);
      if(this->isValid(own->times(), pb.times()))
      {
        own->set_times(pb.times());
        //own->set_timedeltas(pb.timedeltas()); // assumed
        own->set_forwarddeltam(pb.forwarddeltam());
        own->set_rightdeltam(pb.rightdeltam());
        own->set_downdeltam(pb.downdeltam());
      }
    }
    else if(!type.compare("nav.BodyFRDRateDelta"))
    {
      nav::BodyFRDRateDelta pb;
      pb.ParseFromString(data);
      own = this->getEst(id);
      if(this->isValid(own->times(), pb.times()))
      {
        own->set_times(pb.times());
        //own->set_timedeltas(pb.timedeltas()); // assumed
        own->set_forwardratedeltamps(pb.forwardratedeltamps());
        own->set_rightratedeltamps(pb.rightratedeltamps());
        own->set_downratedeltamps(pb.downratedeltamps());
      }
    }
    else if(!type.compare("nav.RelRPY"))
    {
      nav::FusedState* target;
      nav::RelRPY pb;
      double ownLon;
      double ownLat;
      double ownEuler[3];
      double ownQuat[4];
      double ownLonQuat[4];
      double ownLatQuat[4];
      double ownRefQuat[4];
      double targetLon;
      double targetLat;
      double targetEuler[3];
      double targetQuat[4];
      double targetLonQuat[4];
      double targetLatQuat[4];
      double targetRefQuat[4];
      double targetRefQuatInv[4];
      double relEuler[3];
      double relQuat[4];
      pb.ParseFromString(data);
      own = this->getEst(id);
      if(this->est.find(pb.targetid())!=this->est.end())
      {
        target = this->est[pb.targetid()];
        if(this->isValid(target->times(), pb.times()))
        {
          // get target position
          targetLon = target->lonr();
          targetLat = target->latr();
          
          // get ownship position
          ownLon = own->lonr();
          ownLat = own->latr();
          
          // get ownship orientation
          ownEuler[0] = own->rollr();
          ownEuler[1] = own->pitchr();
          ownEuler[2] = own->yawr();
          
          // get relative orientation   
          relEuler[0] = pb.rollr();
          relEuler[1] = pb.pitchr();
          relEuler[2] = pb.yawr();
          
          // compute local reference frame in which ownship frame is defined
          math::Rotation::eulerToQuat(ownLon, 0.0, 0.0, ownLonQuat);
          math::Rotation::eulerToQuat(0.0, -ownLat, 0.0, ownLatQuat);
          math::Rotation::quatMult(ownLonQuat, ownLatQuat, ownRefQuat);
          
          // compute local reference frame in which target frame is defined
          math::Rotation::eulerToQuat(targetLon, 0.0, 0.0, targetLonQuat);
          math::Rotation::eulerToQuat(0.0, -targetLat, 0.0, targetLatQuat);
          math::Rotation::quatMult(targetLonQuat, targetLatQuat, targetRefQuat);
          math::Rotation::quatInv(targetRefQuat, targetRefQuatInv);

          // compute target orientation relative to local reference frame in which ownship frame is defined
          math::Rotation::eulerToQuat(ownEuler, ownQuat);
          math::Rotation::eulerToQuat(relEuler, relQuat);
          math::Rotation::quatMult(ownQuat, relQuat, targetQuat);
          
          // compute target orientation relative to local reference frame in which target frame is defined
          math::Rotation::quatMult(ownRefQuat, targetQuat, targetQuat);
          math::Rotation::quatMult(targetRefQuatInv, targetQuat, targetQuat);
          math::Rotation::quatToEuler(targetQuat, targetEuler);
          
          target->set_times(pb.times());
          target->set_rollr(targetEuler[0]);
          target->set_pitchr(targetEuler[1]);
          target->set_yawr(targetEuler[2]);
        }
      }
    }
    else if(!type.compare("nav.RelFRD"))
    {
      nav::FusedState* target;
      nav::RelFRD pb;
      double ownLon;
      double ownLat;
      double ownAlt;
      double ownECEF[3];
      double ownEuler[3];
      double ownMatrix[3][3];
      double ownLonQuat[4];
      double ownLatQuat[4];
      double ownRefQuat[4];
      double ownRefMatrix[3][3];
      double targetLon;
      double targetLat;
      double targetAlt;
      double targetECEF[3];
      double relFRD[3];
      double relECEF[3];
      pb.ParseFromString(data);
      own = this->getEst(id);
      if(this->est.find(pb.targetid())!=this->est.end())
      {
        target = this->est[pb.targetid()];
        if(this->isValid(target->times(), pb.times()))
        {
          // get ownship position
          ownLon = own->lonr();
          ownLat = own->latr();
          ownAlt = own->altm();
          
          // get ownship orientation
          ownEuler[0] = own->rollr();
          ownEuler[1] = own->pitchr();
          ownEuler[2] = own->yawr();
                    
          // compute local reference frame in which ownship frame is defined
          math::Rotation::eulerToQuat(ownLon, 0.0, 0.0, ownLonQuat);
          math::Rotation::eulerToQuat(0.0, -ownLat, 0.0, ownLatQuat);
          math::Rotation::quatMult(ownLonQuat, ownLatQuat, ownRefQuat);
          
          // compute ownship orientation in the world frame
          math::Rotation::eulerToMatrix(ownEuler, ownMatrix);
          math::Rotation::quatToMatrix(ownRefQuat, ownRefMatrix);
          math::Rotation::mtimes(ownRefMatrix, ownMatrix, ownRefMatrix);
                    
          // get relative orientation
          relFRD[0] = pb.forwardm();
          relFRD[1] = pb.rightm();
          relFRD[2] = pb.downm();
          
          // compute target position relative to local reference frame in which ownship frame is defined
          math::Rotation::mtimes(ownRefMatrix, relFRD, relECEF);
          earth::WGS84::llaToECEF(ownLon, ownLat, ownAlt, ownECEF);
          targetECEF[0] = ownECEF[0]+relECEF[0];
          targetECEF[1] = ownECEF[1]+relECEF[1];
          targetECEF[2] = ownECEF[2]+relECEF[2];
          earth::WGS84::ecefToLLA(targetECEF, targetLon, targetLat, targetAlt);
          
          target->set_times(pb.times());
          target->set_lonr(targetLon);
          target->set_latr(targetLat);
          target->set_altm(targetAlt);
        }
      }
    }
    return;
  }
  
private:
  // robustly get state given identifier
  nav::FusedState* getEst(const std::string& id)
  {
    // if no estimator for this vehicle exists
    if(this->est.find(id)==this->est.end())
    {
      // create the estimator
      this->addTarget(id);
    }
    return(this->est[id]);
  }
  
  // compute validity based on message being recent
  bool isValid(const double& refTime, const double& time)
  {
    return (((this->getTime()-time)<cfg.get<double>("tDanger"))&&(time>=refTime));
  }
  
  void addTarget(const std::string& id)
  {
    nav::FusedState* own = NULL;
    own = new nav::FusedState;
    this->est[id] = own;
    
    // set some defaults
    own->set_times(-INF);
    own->set_timedeltas(this->timeDeltaS);
    
    own->set_rolldeltar(0.0);
    own->set_pitchdeltar(0.0);
    own->set_yawdeltar(0.0);
    
    own->set_forwardratedeltamps(0.0);
    own->set_rightratedeltamps(0.0);
    own->set_downratedeltamps(0.0);
    return;
  }
    
  void onTick(void)
  {
    std::string outbox;
    std::string ownID;
    std::string targetID;
    nav::FusedState* ownState;
    nav::FusedState* targetState;
    std::map< std::string, nav::FusedState* >::iterator ownItr;
    std::map< std::string, nav::FusedState* >::iterator targetItr;
    
    // for all vehicles
    for(ownItr = this->est.begin(); ownItr!=this->est.end(); ++ownItr)
    {      
      // get own state
      ownState = ownItr->second;
      
      // if own state is initialized
      if(ownState->IsInitialized())
      {
        // output own state
        ownID = ownItr->first;
        Msg::Proto::pack("nav.FusedState", ownID, ownState->SerializeAsString(), outbox);
        this->send(outbox);
        
        // for all target vehicles
        for(targetItr = this->est.begin(); targetItr!=this->est.end(); ++targetItr)
        {
          // if this is a unique combination
          if(ownItr!=targetItr)
          {
            // get target state
            targetState = targetItr->second;
            
            // if target state is initialized
            if(targetState->IsInitialized())
            {
              // output relative fused state
              targetID = targetItr->first;
              sendRelFusedState(ownID, ownState, targetID, targetState);
            }
          }
        }
      }
    }
    return;
  }
  
  // TODO: compute more precisely (and maybe efficiently) based on relative measurement code above
  void sendRelFusedState(const std::string& ownID, const nav::FusedState* own, const std::string& targetID,
    const nav::FusedState* target)
  {
    std::string outbox;
    nav::RelFusedState rel;
    
    double ownEuler[3];
    double ownQuat[4];
    double ownQuatInv[4];
    double ownMatrixInv[3][3];
    
    double targetEuler[3];
    double targetQuat[4];
    double targetMatrix[3][3];
    
    double relQuat[4];
    double relEuler[3];

    double ownLat;
    double ownLon;
    double ownAlt;
    double rLat;
    double rLon;
    double relNED[3];
    double relFRD[3];

    double ownFRDDelta[3];
    double targetFRDDelta[3];
    double targetNEDDelta[3];
    double relFRDDelta[3];

    // time and identifiers
    rel.set_ownid(ownID);
    rel.set_targetid(targetID);
    rel.set_times(own->times());
    
    // own orientation
    ownEuler[0] = own->rollr();
    ownEuler[1] = own->pitchr();
    ownEuler[2] = own->yawr();
    math::Rotation::eulerToQuat(ownEuler , ownQuat);
    math::Rotation::quatInv(ownQuat, ownQuatInv);
    math::Rotation::quatToMatrix(ownQuatInv, ownMatrixInv);
    
    // target orientation
    targetEuler[0] = target->rollr();
    targetEuler[1] = target->pitchr();
    targetEuler[2] = target->yawr();
    math::Rotation::eulerToQuat(targetEuler, targetQuat);
    math::Rotation::quatToMatrix(targetQuat, targetMatrix);
    
    // relative orientation
    math::Rotation::quatMult(ownQuatInv, targetQuat, relQuat); // approximate
    math::Rotation::quatToEuler(relQuat, relEuler);   
    rel.set_rollr(relEuler[0]);
    rel.set_pitchr(relEuler[1]);
    rel.set_yawr(relEuler[2]);

    // relative position
    ownLat = own->latr();
    ownLon = own->lonr();
    ownAlt = own->altm();
    rLat = earth::WGS84::radiusOfCurvature(ownLat)+ownAlt;
    rLon = cos(earth::WGS84::geodeticToGeocentric(ownLat))*earth::WGS84::geodeticRadius(ownLat)+ownAlt;
    relNED[0] = rLat*(target->latr()-ownLat);
    relNED[1] = rLon*(target->lonr()-ownLon);
    relNED[2] = -(target->altm()-ownAlt);
    math::Rotation::mtimes(ownMatrixInv, relNED, relFRD); 
    rel.set_forwardm(relFRD[0]);
    rel.set_rightm(relFRD[1]);
    rel.set_downm(relFRD[2]);

    // relative velocity
    ownFRDDelta[0] = own->forwarddeltam();
    ownFRDDelta[1] = own->rightdeltam();
    ownFRDDelta[2] = own->downdeltam();
    targetFRDDelta[0] = target->forwarddeltam();
    targetFRDDelta[1] = target->rightdeltam();
    targetFRDDelta[2] = target->downdeltam();
    math::Rotation::mtimes(targetMatrix, targetFRDDelta, targetNEDDelta);
    math::Rotation::mtimes(ownMatrixInv, targetNEDDelta, relFRDDelta); // approximate
    relFRDDelta[0] -= ownFRDDelta[0];
    relFRDDelta[1] -= ownFRDDelta[1];
    relFRDDelta[2] -= ownFRDDelta[2];
    rel.set_forwarddeltam(relFRDDelta[0]);
    rel.set_rightdeltam(relFRDDelta[1]);
    rel.set_downdeltam(relFRDDelta[2]);
    
    Msg::Proto::pack("nav.RelFusedState", ownID, rel.SerializeAsString(), outbox);
    this->send(outbox);
  }
};
  
int main(int argc, char* argv[])
{
  if(argc<3)
  {
    printf("usage: ARDEstimator subURI pubURI\n");
    return EXIT_FAILURE;
  }
  ARDEstimator app;
  Msg::Exec* msgExec = Msg::Exec::getInstance(cfg.get<double>("timeWarp"));
  msgExec->start(&app, argv[1], argv[2]);
  return EXIT_FAILURE;
}
