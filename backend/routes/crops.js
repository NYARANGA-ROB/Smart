const express = require('express');
const { body, validationResult } = require('express-validator');
const { getAdminFirestore } = require('../config/firebase');
const { logger, businessLogger } = require('../utils/logger');
const { analyzeSoil } = require('../services/soilAnalysisService');
const { getCropRecommendations } = require('../services/cropRecommendationService');
const { getFertilizerRecommendations } = require('../services/fertilizerService');
const { getPesticideRecommendations } = require('../services/pesticideService');

const router = express.Router();

// Validation middleware
const validateSoilAnalysis = [
  body('location').isObject(),
  body('location.lat').isFloat(),
  body('location.lng').isFloat(),
  body('soilType').isString(),
  body('phLevel').isFloat({ min: 0, max: 14 }),
  body('nitrogen').isFloat({ min: 0 }),
  body('phosphorus').isFloat({ min: 0 }),
  body('potassium').isFloat({ min: 0 }),
  body('organicMatter').isFloat({ min: 0, max: 100 }),
  body('moisture').isFloat({ min: 0, max: 100 })
];

const validateCropPlanning = [
  body('farmId').isString(),
  body('season').isIn(['spring', 'summer', 'autumn', 'winter', 'rainy', 'dry']),
  body('availableWater').isFloat({ min: 0 }),
  body('budget').isFloat({ min: 0 }),
  body('laborAvailability').isIn(['low', 'medium', 'high']),
  body('marketDemand').isObject()
];

// Get crop recommendations based on soil analysis
router.post('/recommendations', validateSoilAnalysis, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const {
      location,
      soilType,
      phLevel,
      nitrogen,
      phosphorus,
      potassium,
      organicMatter,
      moisture,
      season,
      availableWater,
      budget,
      laborAvailability,
      marketDemand
    } = req.body;

    // Analyze soil conditions
    const soilAnalysis = await analyzeSoil({
      location,
      soilType,
      phLevel,
      nitrogen,
      phosphorus,
      potassium,
      organicMatter,
      moisture
    });

    // Get crop recommendations
    const recommendations = await getCropRecommendations({
      soilAnalysis,
      location,
      season: season || 'current',
      availableWater,
      budget,
      laborAvailability,
      marketDemand
    });

    // Get fertilizer recommendations for top crops
    const topCrops = recommendations.slice(0, 3);
    const fertilizerRecommendations = await Promise.all(
      topCrops.map(async (crop) => {
        const fertilizers = await getFertilizerRecommendations({
          crop: crop.name,
          soilAnalysis,
          budget: budget * 0.3 // 30% of budget for fertilizers
        });
        return {
          crop: crop.name,
          fertilizers
        };
      })
    );

    businessLogger('crops', 'recommendations_generated', {
      userId: req.user.uid,
      location,
      soilType,
      season
    });

    res.json({
      message: 'Crop recommendations generated successfully',
      soilAnalysis,
      recommendations,
      fertilizerRecommendations,
      timestamp: new Date().toISOString()
    });

  } catch (error) {
    logger.error('Crop recommendation error:', error);
    res.status(500).json({
      error: 'Recommendation generation failed',
      message: 'Unable to generate crop recommendations'
    });
  }
});

// Get crop details and growing guide
router.get('/:cropId', async (req, res) => {
  try {
    const { cropId } = req.params;
    const db = getAdminFirestore();

    const cropDoc = await db.collection('crops').doc(cropId).get();

    if (!cropDoc.exists) {
      return res.status(404).json({
        error: 'Crop not found',
        message: 'The specified crop does not exist'
      });
    }

    const cropData = cropDoc.data();

    // Get growing guide
    const growingGuide = {
      plantingTime: cropData.plantingTime,
      harvestTime: cropData.harvestTime,
      waterRequirements: cropData.waterRequirements,
      soilRequirements: cropData.soilRequirements,
      pestManagement: cropData.pestManagement,
      diseaseManagement: cropData.diseaseManagement,
      harvestingTips: cropData.harvestingTips,
      storageTips: cropData.storageTips
    };

    res.json({
      message: 'Crop details retrieved successfully',
      crop: cropData,
      growingGuide
    });

  } catch (error) {
    logger.error('Crop details error:', error);
    res.status(500).json({
      error: 'Failed to retrieve crop details',
      message: 'Unable to fetch crop information'
    });
  }
});

// Plan crop planting
router.post('/plan', validateCropPlanning, async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const {
      farmId,
      cropId,
      area,
      plantingDate,
      expectedHarvestDate,
      seedQuantity,
      fertilizerPlan,
      irrigationPlan,
      pestManagementPlan,
      budget,
      notes
    } = req.body;

    const db = getAdminFirestore();

    // Create crop plan
    const cropPlan = {
      id: `${farmId}_${cropId}_${Date.now()}`,
      farmId,
      cropId,
      userId: req.user.uid,
      area,
      plantingDate: new Date(plantingDate),
      expectedHarvestDate: new Date(expectedHarvestDate),
      seedQuantity,
      fertilizerPlan,
      irrigationPlan,
      pestManagementPlan,
      budget,
      notes,
      status: 'planned',
      createdAt: new Date(),
      updatedAt: new Date(),
      progress: {
        planted: false,
        fertilized: false,
        irrigated: false,
        pestControl: false,
        harvested: false
      },
      costs: {
        seeds: 0,
        fertilizers: 0,
        irrigation: 0,
        pestControl: 0,
        labor: 0,
        total: 0
      },
      yields: {
        expected: 0,
        actual: 0,
        quality: 'pending'
      }
    };

    await db.collection('cropPlans').doc(cropPlan.id).set(cropPlan);

    // Update farm statistics
    const farmRef = db.collection('farms').doc(farmId);
    await farmRef.update({
      totalPlannedArea: admin.firestore.FieldValue.increment(area),
      cropPlans: admin.firestore.FieldValue.arrayUnion(cropPlan.id),
      updatedAt: new Date()
    });

    businessLogger('crops', 'crop_plan_created', {
      userId: req.user.uid,
      farmId,
      cropId,
      area,
      budget
    });

    res.status(201).json({
      message: 'Crop plan created successfully',
      cropPlan
    });

  } catch (error) {
    logger.error('Crop planning error:', error);
    res.status(500).json({
      error: 'Crop planning failed',
      message: 'Unable to create crop plan'
    });
  }
});

// Update crop plan progress
router.put('/plan/:planId/progress', async (req, res) => {
  try {
    const { planId } = req.params;
    const { stage, completed, notes, costs } = req.body;

    const db = getAdminFirestore();

    const planRef = db.collection('cropPlans').doc(planId);
    const planDoc = await planRef.get();

    if (!planDoc.exists) {
      return res.status(404).json({
        error: 'Crop plan not found',
        message: 'The specified crop plan does not exist'
      });
    }

    const planData = planDoc.data();

    // Check if user has access to this plan
    if (planData.userId !== req.user.uid && planData.farmId !== req.user.farmId) {
      return res.status(403).json({
        error: 'Access denied',
        message: 'You do not have access to this crop plan'
      });
    }

    const updates = {
      updatedAt: new Date(),
      [`progress.${stage}`]: completed
    };

    if (notes) {
      updates.notes = `${planData.notes || ''}\n${new Date().toISOString()}: ${notes}`;
    }

    if (costs) {
      Object.keys(costs).forEach(costType => {
        updates[`costs.${costType}`] = admin.firestore.FieldValue.increment(costs[costType]);
      });
    }

    await planRef.update(updates);

    businessLogger('crops', 'crop_plan_updated', {
      userId: req.user.uid,
      planId,
      stage,
      completed
    });

    res.json({
      message: 'Crop plan progress updated successfully'
    });

  } catch (error) {
    logger.error('Crop plan update error:', error);
    res.status(500).json({
      error: 'Update failed',
      message: 'Unable to update crop plan progress'
    });
  }
});

// Get pesticide recommendations
router.post('/pesticides', [
  body('cropId').isString(),
  body('pestType').isIn(['insects', 'diseases', 'weeds']),
  body('severity').isIn(['low', 'medium', 'high']),
  body('budget').isFloat({ min: 0 })
], async (req, res) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { cropId, pestType, severity, budget } = req.body;

    const recommendations = await getPesticideRecommendations({
      cropId,
      pestType,
      severity,
      budget
    });

    businessLogger('crops', 'pesticide_recommendations', {
      userId: req.user.uid,
      cropId,
      pestType,
      severity
    });

    res.json({
      message: 'Pesticide recommendations generated successfully',
      recommendations
    });

  } catch (error) {
    logger.error('Pesticide recommendation error:', error);
    res.status(500).json({
      error: 'Recommendation generation failed',
      message: 'Unable to generate pesticide recommendations'
    });
  }
});

// Get crop calendar for a farm
router.get('/calendar/:farmId', async (req, res) => {
  try {
    const { farmId } = req.params;
    const { year } = req.query;

    const db = getAdminFirestore();

    // Get all crop plans for the farm
    const plansSnapshot = await db.collection('cropPlans')
      .where('farmId', '==', farmId)
      .get();

    const calendar = [];
    plansSnapshot.forEach(doc => {
      const plan = doc.data();
      const planYear = new Date(plan.plantingDate).getFullYear();
      
      if (!year || planYear === parseInt(year)) {
        calendar.push({
          id: doc.id,
          cropId: plan.cropId,
          title: plan.cropName,
          start: plan.plantingDate.toDate(),
          end: plan.expectedHarvestDate.toDate(),
          status: plan.status,
          area: plan.area
        });
      }
    });

    res.json({
      message: 'Crop calendar retrieved successfully',
      calendar
    });

  } catch (error) {
    logger.error('Crop calendar error:', error);
    res.status(500).json({
      error: 'Failed to retrieve crop calendar',
      message: 'Unable to fetch calendar data'
    });
  }
});

// Get crop statistics
router.get('/stats/:farmId', async (req, res) => {
  try {
    const { farmId } = req.params;
    const { period } = req.query; // monthly, quarterly, yearly

    const db = getAdminFirestore();

    // Get crop plans and calculate statistics
    const plansSnapshot = await db.collection('cropPlans')
      .where('farmId', '==', farmId)
      .get();

    const stats = {
      totalPlans: 0,
      completedPlans: 0,
      totalArea: 0,
      totalCosts: 0,
      totalYield: 0,
      averageYield: 0,
      topCrops: [],
      monthlyBreakdown: {}
    };

    const cropCounts = {};

    plansSnapshot.forEach(doc => {
      const plan = doc.data();
      stats.totalPlans++;
      stats.totalArea += plan.area || 0;
      stats.totalCosts += plan.costs?.total || 0;
      stats.totalYield += plan.yields?.actual || 0;

      if (plan.status === 'completed') {
        stats.completedPlans++;
      }

      // Count crops
      if (plan.cropId) {
        cropCounts[plan.cropId] = (cropCounts[plan.cropId] || 0) + 1;
      }

      // Monthly breakdown
      const month = new Date(plan.plantingDate).getMonth();
      if (!stats.monthlyBreakdown[month]) {
        stats.monthlyBreakdown[month] = {
          plans: 0,
          area: 0,
          costs: 0
        };
      }
      stats.monthlyBreakdown[month].plans++;
      stats.monthlyBreakdown[month].area += plan.area || 0;
      stats.monthlyBreakdown[month].costs += plan.costs?.total || 0;
    });

    stats.averageYield = stats.totalPlans > 0 ? stats.totalYield / stats.totalPlans : 0;

    // Get top crops
    stats.topCrops = Object.entries(cropCounts)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 5)
      .map(([cropId, count]) => ({ cropId, count }));

    res.json({
      message: 'Crop statistics retrieved successfully',
      stats
    });

  } catch (error) {
    logger.error('Crop statistics error:', error);
    res.status(500).json({
      error: 'Failed to retrieve crop statistics',
      message: 'Unable to fetch statistics data'
    });
  }
});

module.exports = router; 