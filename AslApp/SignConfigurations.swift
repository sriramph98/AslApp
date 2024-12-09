import Vision
import CoreGraphics

struct SignConfigurations {
    // Common words/phrases
    static let commonPhrases: [String: (([VNHumanHandPoseObservation.JointName: CGPoint]) -> Bool)] = [
        "HELLO": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // Flat hand, fingers together, palm facing forward, moving side to side
            let fingersExtended = indexTip.y > indexMcp.y + 0.15
            let thumbParallel = abs(thumbTip.y - indexTip.y) < 0.1
            
            return fingersExtended && thumbParallel
        },
        
        "THANK YOU": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // Flat hand moving forward from chin
            let handPosition = indexTip.y > thumbTip.y
            let fingersExtended = indexTip.y > indexMcp.y + 0.15
            
            return handPosition && fingersExtended
        },
        
        "PLEASE": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip] else {
                return false
            }
            
            // Flat hand circling over heart
            let handFlat = abs(thumbTip.y - indexTip.y) < 0.1
            return handFlat
        },
        
        "YES": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // Fist nodding up and down
            let fistPosition = indexTip.y < indexMcp.y
            return fistPosition
        },
        
        "NO": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // Index finger wagging side to side
            let indexOut = abs(indexTip.x - indexMcp.x) > 0.1
            return indexOut
        },
        
        "I LOVE YOU": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let littleTip = landmarks[.littleTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // Thumb, index, and pinky extended
            let thumbOut = thumbTip.x < indexMcp.x
            let indexUp = indexTip.y > indexMcp.y
            let pinkyUp = littleTip.y > indexMcp.y
            
            return thumbOut && indexUp && pinkyUp
        }
    ]
    
    // Numbers 0-9
    static let numbers: [String: (([VNHumanHandPoseObservation.JointName: CGPoint]) -> Bool)] = [
        "0": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip] else {
                return false
            }
            
            // Thumb and index form "O"
            let isCircular = abs(thumbTip.x - indexTip.x) < 0.05 &&
                            abs(thumbTip.y - indexTip.y) < 0.05
            
            return isCircular
        },
        
        "1": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let indexMcp = landmarks[.indexMCP],
                  let middleTip = landmarks[.middleTip],
                  let ringTip = landmarks[.ringTip],
                  let littleTip = landmarks[.littleTip] else {
                return false
            }
            
            // Index up, others down
            let indexUp = indexTip.y > indexMcp.y + 0.15
            let othersDown = middleTip.y < indexMcp.y &&
                            ringTip.y < indexMcp.y &&
                            littleTip.y < indexMcp.y
            
            return indexUp && othersDown
        },
        
        "2": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let indexMcp = landmarks[.indexMCP],
                  let ringTip = landmarks[.ringTip],
                  let littleTip = landmarks[.littleTip] else {
                return false
            }
            
            // Index and middle up, spread
            let twoUp = indexTip.y > indexMcp.y + 0.15 &&
                       middleTip.y > indexMcp.y + 0.15
            let spread = abs(indexTip.x - middleTip.x) > 0.1
            let othersDown = ringTip.y < indexMcp.y &&
                            littleTip.y < indexMcp.y
            
            return twoUp && spread && othersDown
        },
        
        "3": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let ringTip = landmarks[.ringTip],
                  let indexMcp = landmarks[.indexMCP],
                  let littleTip = landmarks[.littleTip] else {
                return false
            }
            
            // Three fingers up
            let threeUp = indexTip.y > indexMcp.y + 0.15 &&
                         middleTip.y > indexMcp.y + 0.15 &&
                         ringTip.y > indexMcp.y + 0.15
            let pinkyDown = littleTip.y < indexMcp.y
            
            return threeUp && pinkyDown
        },
        
        "4": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let ringTip = landmarks[.ringTip],
                  let littleTip = landmarks[.littleTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // All fingers up except thumb
            let fingersUp = indexTip.y > indexMcp.y + 0.15 &&
                           middleTip.y > indexMcp.y + 0.15 &&
                           ringTip.y > indexMcp.y + 0.15 &&
                           littleTip.y > indexMcp.y + 0.15
            
            return fingersUp
        },
        
        "5": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let ringTip = landmarks[.ringTip],
                  let littleTip = landmarks[.littleTip],
                  let thumbTip = landmarks[.thumbTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // All fingers spread
            let allUp = indexTip.y > indexMcp.y + 0.15 &&
                       middleTip.y > indexMcp.y + 0.15 &&
                       ringTip.y > indexMcp.y + 0.15 &&
                       littleTip.y > indexMcp.y + 0.15 &&
                       thumbTip.y > indexMcp.y
            
            let spread = abs(indexTip.x - littleTip.x) > 0.2
            
            return allUp && spread
        },
        
        "6": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let littleTip = landmarks[.littleTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // Thumb pointing to pinky
            let thumbOut = thumbTip.x < indexMcp.x
            let pinkyPosition = littleTip.y < indexMcp.y
            
            return thumbOut && pinkyPosition
        },
        
        "7": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let ringTip = landmarks[.ringTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // Thumb, index, and middle up
            let thumbUp = thumbTip.y > indexMcp.y
            let indexUp = indexTip.y > indexMcp.y
            let ringDown = ringTip.y < indexMcp.y
            
            return thumbUp && indexUp && ringDown
        },
        
        "8": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let indexMcp = landmarks[.indexMCP] else {
                return false
            }
            
            // Thumb points to middle finger
            let thumbPosition = abs(thumbTip.x - middleTip.x) < 0.1
            let indexUp = indexTip.y > indexMcp.y
            
            return thumbPosition && indexUp
        },
        
        "9": { landmarks in
            guard let indexTip = landmarks[.indexTip],
                  let indexMcp = landmarks[.indexMCP],
                  let thumbTip = landmarks[.thumbTip] else {
                return false
            }
            
            // Index down, thumb out
            let indexDown = indexTip.y < indexMcp.y
            let thumbOut = thumbTip.x < indexMcp.x
            
            return indexDown && thumbOut
        }
    ]
    
    // Add letter configurations
    static let letterConfigurations: [String: (([VNHumanHandPoseObservation.JointName: CGPoint]) -> Bool)] = [
        "A": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let thumbIP = landmarks[.thumbIP],
                  let indexTip = landmarks[.indexTip],
                  let indexMCP = landmarks[.indexMCP],
                  let middleTip = landmarks[.middleTip],
                  let middleMCP = landmarks[.middleMCP],
                  let ringTip = landmarks[.ringTip],
                  let ringMCP = landmarks[.ringMCP],
                  let littleTip = landmarks[.littleTip],
                  let littleMCP = landmarks[.littleMCP] else {
                return false
            }
            
            let fingersAreClosed = indexTip.y < indexMCP.y &&
                                 middleTip.y < middleMCP.y &&
                                 ringTip.y < ringMCP.y &&
                                 littleTip.y < littleMCP.y
            
            let thumbExtended = abs(thumbTip.x - thumbIP.x) > 0.05
            
            return fingersAreClosed && thumbExtended
        },
        
        "B": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let indexMCP = landmarks[.indexMCP],
                  let middleTip = landmarks[.middleTip],
                  let middleMCP = landmarks[.middleMCP],
                  let ringTip = landmarks[.ringTip],
                  let ringMCP = landmarks[.ringMCP],
                  let littleTip = landmarks[.littleTip],
                  let littleMCP = landmarks[.littleMCP] else {
                return false
            }
            
            let fingersExtended = indexTip.y > indexMCP.y + 0.1 &&
                                middleTip.y > middleMCP.y + 0.1 &&
                                ringTip.y > ringMCP.y + 0.1 &&
                                littleTip.y > littleMCP.y + 0.1
            
            let fingerSpread = abs(indexTip.x - littleTip.x)
            let fingersClose = fingerSpread < 0.15
            
            let thumbTucked = thumbTip.x > indexMCP.x
            
            return fingersExtended && fingersClose && thumbTucked
        },
        
        "C": { landmarks in
            guard let thumbTip = landmarks[.thumbTip],
                  let indexTip = landmarks[.indexTip],
                  let middleTip = landmarks[.middleTip],
                  let ringTip = landmarks[.ringTip],
                  let littleTip = landmarks[.littleTip] else {
                return false
            }
            
            let fingersAligned = abs(indexTip.y - middleTip.y) < 0.1 &&
                               abs(middleTip.y - ringTip.y) < 0.1 &&
                               abs(ringTip.y - littleTip.y) < 0.1
            
            let isCurved = abs(thumbTip.x - littleTip.x) < 0.2
            
            return fingersAligned && isCurved
        }
        
        // Add more letters here...
    ]
} 
